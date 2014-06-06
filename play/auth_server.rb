require 'konin'

class AuthService
  def authenticate(login, password)
    login == 'root' && password == 'root'
  end
end

server = Konin::RPCServer.new 'auth', handlers: { AuthService: AuthService.new }

server.start
