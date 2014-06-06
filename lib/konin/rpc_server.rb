module Konin
  class RPCServer
    def self.start(*args)
      new(*args).start
    end

    attr_reader :queue
    attr_reader :handlers

    def initialize(prefix, handlers:)
      @handlers = handlers

      @queue = Queue.new "#{prefix}_rpc_queue"
    end

    def start
      queue.rpc_loop do |payload|
        iface = payload['interface'].to_sym
        fun = payload['function']
        args = payload['args']

        res = handlers[iface].send(fun, *args)

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
