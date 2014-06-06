require 'konin'

client = Konin::RPCClient.new auth: 'auth.json', calc: 'calc.json'

AuthService = client[:auth][:AuthService]
CalculatorService = client[:calc][:CalculatorService]

def authenticate(login, password)
  if AuthService.authenticate(login, password)
    puts "Access granted: #{login}"
    true
  else
    puts "Access denied: #{login}"
    false
  end
end

if authenticate 'me', 'me'
  puts CalculatorService.add(1, 2)
end

if authenticate 'root', 'root'
  puts CalculatorService.add(11, 31)
end

client.close
