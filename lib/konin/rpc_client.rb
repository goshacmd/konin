module Konin
  class RPCClient
    attr_reader :queue
    attr_reader :prefixes

    def initialize(prefixes = {})
      @prefixes = prefixes

      @queue = Queue.new '', exclusive: true
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
      request = { interface: interface, function: function, args: args }

      response = queue.rpc_request(request, "#{prefix}_rpc_queue")

      response['result']
    end

    def close
      queue.close
    end
  end
end
