module Konin
  class Contract
    class Function < Struct.new(:name, :params, :returns); end
    class Interface < Struct.new(:name, :functions); end

    def self.from_file(path, prefix)
      new(prefix, JSON.parse(IO.read(path)))
    end

    attr_reader :prefix
    attr_reader :interfaces

    def initialize(prefix, data)
      @prefix = prefix

      @interfaces = data.select { |i| i['type'] == 'interface' }.map do |iface|
        functions = iface['functions'].map do |f|
          returns = f['returns'].values_at('type', 'is_array')
          params = f['params'].map { |p| p.values_at('type', 'is_array') }

          Function.new(f['name'].to_sym, params, returns)
        end

        Interface.new(iface['name'].to_sym, functions)
      end
    end

    def handlers(client)
      interfaces.map do |iface|
        [iface.name, handler_for(iface, client)]
      end.to_h
    end

    def handler_for(iface, client)
      p = prefix
      Class.new do
        iface.functions.each do |f|
          define_singleton_method(f.name) { |*args| client.call(p, iface.name, f.name, args) }
        end
      end
    end
  end
end
