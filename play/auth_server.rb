require 'konin'

class AuthService
  def authenticate(login, password)
    login == 'root' && password == 'root'
  end
end

Konin::RPCServer.start 'auth.json', AuthService
