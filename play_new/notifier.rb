require 'konin'

class NotifierService
  include Konin::Service

  def push_notification(data)
    puts data
  end

  def p
    deps[:accounts].authenticate(:root, :root)
  end
end

class SucceededAuthenticationConsumer
  include Konin::Consumer
  consumer :accounts, :authentication, :succeeded

  def process(attempt)
    service.push_notification "auth succ: #{attempt[:login]}"
  end
end

class FailedAuthenticationConsumer
  include Konin::Consumer
  consume :accounts, :authentication, :failed

  def process(attempt)
    service.push_notification "auth fail: #{attempt[:login]}"
  end
end

Konin::Service.start(NotifierService, 'contracts/notifier.json') do |s|
  s.dependencies accounts: 'contracts/accounts.json'
end

# starts RPC server
# starts accounts notification consumers
