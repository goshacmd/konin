module Konin
  class Queue
    attr_reader :conn, :ch, :q, :x

    def initialize(queue = '', queue_opts = {})
      @conn = Bunny.new
      @conn.start

      @ch = conn.create_channel
      @q = ch.queue queue, queue_opts
      @x = ch.default_exchange
    end

    def subscribe(&block)
      q.subscribe(block: true, &block)
    end

    def publish(*args)
      x.publish(*args)
    end

    def rpc_request(data, routing_key)
      cid = SecureRandom.uuid

      publish(JSON.dump(data), routing_key: routing_key, correlation_id: cid, reply_to: q.name)

      response = nil

      subscribe do |delivery_info, properties, payload|
        if properties.correlation_id == cid
          response = JSON.parse(payload)
          delivery_info.consumer.cancel
        end
      end

      response
    end

    def rpc_loop(&block)
      subscribe do |delivery_info, properties, payload|
        payload = JSON.parse(payload)
        response = yield(payload)
        publish(JSON.dump(response), routing_key: properties.reply_to, correlation_id: properties.correlation_id)
      end
    end

    def close
      ch.close
      conn.close
    end
  end
end
