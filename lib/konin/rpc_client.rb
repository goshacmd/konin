module Konin
  class RPCClient
    attr_reader :queue
    attr_reader :services

    def initialize(services = {})
      @services = services

      @queue = Queue.new '', exclusive: true
    end

    def contracts
      @contracts ||= services.map { |name, file| [name, Contract.from_file(file)] }.to_h
    end

    def handlers
      @handlers ||= contracts.map { |name, contract| [name, contract.handler_for(self)] }.to_h
    end

    def [](name)
      handlers[name.to_sym]
    end

    def call(ns, function, args)
      request = { function: function, args: args }

      response = queue.rpc_request(request, [ns, 'rpc'].join(':'))

      response['result']
    end

    def close
      queue.close
    end
  end
end
