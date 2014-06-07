module Konin
  class RPCServer
    def self.start(*args)
      new(*args).start
    end

    attr_reader :queue
    attr_reader :contract
    attr_reader :handler

    def initialize(file_path, handler)
      @contract = Contract.from_file(file_path)
      @handler = handler.new

      @queue = Queue.new [contract.namespace, 'rpc'].join(':')
    end

    def start
      queue.rpc_loop do |payload|
        fun = payload['function']
        args = payload['args']

        res = handler.send(fun, *args)

        { result: res }
      end
    rescue Interrupt => _
      close
    end

    def close
      queue.close
    end
  end
end
