require 'konin'

class CalculatorService
  def add(n1, n2)
    n1.to_i + n2.to_i
  end
end

Konin::RPCServer.start 'calc.json', CalculatorService
