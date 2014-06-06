# Konin

![Konin](konin.png)

Konin is a RabbitMQ-powered library to enable synchronous inter-service
communication (RPC) in a service-oriented architecture.

## Installation

Add this line to your application's Gemfile:

    gem 'konin'

## Quick start

auth.idl:

```idl
interface AuthService {
  authenticate(login string, password string) bool
}
```

auth_server.rb:

```ruby
require 'konin'

class AuthService
  def authenticate(login, password)
    login == 'root' && password == 'root'
  end
end

Konin::RPCServer.start 'auth', handlers: { AuthService: AuthService.new }
```

client.rb

```ruby
require 'konin'

client = Konin::RPCClient.new auth: 'auth.json'

AuthService = client[:auth][:AuthService]

def authenticate(login, password)
  if AuthService.authenticate(login, password)
    puts "Access granted: #{login}"
  else
    puts "Access denied: #{login}"
  end
end

authenticate 'me', 'me'
authenticate 'root', 'root'

client.close
```

Then

```bash
$ ruby auth_server.rb &
$ ruby client.rb
Access denied: me
Access granted: root
```

## TODO

* generate structs
* enforce idl schema
* msgpack instead of json (?)

## Contributing

1. Fork it (https://github.com/goshakkk/konin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT.
