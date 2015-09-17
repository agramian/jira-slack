# configure port
#\ -p 9494

require './app'

set :lock, true

configure :production do
  set :bind, '0.0.0.0'
end

run Sinatra::Application
