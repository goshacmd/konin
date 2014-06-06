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

    def descriptions
      @description ||= prefixes.map { |p, f| [p, DescriptionParser.parse(f)] }.to_h
    end

    def interfaces
      @interfaces ||=
        descriptions.map do |prefix, description|
          [prefix, description.map { |i| [i[:name].to_sym, InterfaceGenerator.generate(prefix, i, self)] }.to_h]
        end.to_h
    end

    def [](prefix)
      interfaces[prefix]
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
