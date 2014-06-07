require 'konin'

class AccountsService
  include Konin::Service

  def authenticate(login, password)
    res = login == 'root' && password == 'root'
    action = res ? :succeeded : :failed
    notify :authentication, action, login: login
    res
  end
end

Konin::Service.start(AccountsService, 'contracts/accounts.json')
