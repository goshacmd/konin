module Konin
  class DescriptionParser
    attr_reader :fp

    def self.parse(fp)
      new(fp).parse
    end

    def initialize(fp)
      @fp = fp
    end

    def contents
      @contents ||= IO.read fp
    end

    def parse
      interfaces = JSON.parse(contents).select { |i| i['type'] == 'interface' }

      interfaces.map do |iface|
        functions = iface['functions'].map do |f|
          returns = f['returns'].values_at('type', 'is_array')
          params = f['params'].map { |p| p.values_at('type', 'is_array') }

          { name: f['name'], params: params, returns: returns }
        end

        { name: iface['name'], functions: functions }
      end
    end
  end
end
