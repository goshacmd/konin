module Konin
  class RPCClient
    attr_reader :conn, :ch, :x, :reply_queue
    attr_reader :prefixes

    def initialize(prefixes = {})
      @prefixes = prefixes

      @conn = Bunny.new
      @conn.start

      @ch = conn.create_channel

      @x = ch.default_exchange

      @reply_queue = ch.queue('', exclusive: true)
    end

    def contracts
      @contracts ||= prefixes.map { |p, f| [p, Contract.from_file(f, p)] }.to_h
    end

    def handlers
      @handlers ||= contracts.map { |p, c| [p, c.handlers(self)] }.to_h
    end

    def [](prefix)
      handlers[prefix.to_sym]
    end

    def call(prefix, interface, function, args)
      correlation_id = SecureRandom.uuid

      request = { interface: interface, function: function, args: args }

      x.publish(JSON.dump(request), routing_key: "#{prefix}_rpc_queue", correlation_id: correlation_id, reply_to: reply_queue.name)

      response = nil

      reply_queue.subscribe(block: true) do |delivery_info, properties, payload|
        if properties.correlation_id == correlation_id
          response = JSON.parse(payload)['result']
          delivery_info.consumer.cancel
        end
      end

      response
    end

    def close
      ch.close
      conn.close
    end
  end
end
