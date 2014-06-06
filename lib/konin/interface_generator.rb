module Konin
  class InterfaceGenerator
    class << self
      def generate(prefix, iface, client)
        Class.new do
          iface[:functions].each do |f|
            define_singleton_method(f[:name]) do |*args|
              client.call(prefix, iface[:name], f[:name], args)
            end
          end
        end
      end
    end
  end
end
