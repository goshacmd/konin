module Konin
  class RPCServer
    attr_reader :conn, :ch, :q, :x
    attr_reader :interfaces

    def initialize(prefix, interfaces:)
      @interfaces = interfaces

      @conn = Bunny.new
      @conn.start

      @ch = conn.create_channel

      @q = ch.queue "#{prefix}_rpc_queue"
      @x = ch.default_exchange
    end

    def start
      q.subscribe(block: true) do |delivery_info, properties, payload|
        payload = JSON.parse(payload)
        iface = payload['interface'].to_sym
        fun = payload['function']
        args = payload['args']

        res = interfaces[iface].send(fun, *args)

        x.publish(JSON.dump(result: res), routing_key: properties.reply_to, correlation_id: properties.correlation_id)
      end
    rescue Interrupt => _
      close
    end

    def close
      ch.close
      conn.close
    end
  end
end
