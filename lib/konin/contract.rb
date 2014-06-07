module Konin
  class Contract
    class Function < Struct.new(:name, :params, :returns); end

    def self.from_file(path)
      new(JSON.parse(IO.read(path)))
    end

    attr_reader :namespace, :functions

    def initialize(data)
      @namespace = data['namespace']

      @functions = data['service_interface']['functions'].map do |(name, params, returns)|
        Function.new(name.to_sym, params, returns)
      end
    end

    def handler_for(client)
      ns = namespace
      fs = functions
      Class.new do
        fs.each do |f|
          define_singleton_method(f.name) { |*args| client.call(ns, f.name, args) }
        end
      end
    end
  end
end
