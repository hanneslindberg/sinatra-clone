# frozen_string_literal: true

require_relative 'lib/tcp_server'
require_relative 'lib/router'
require 'debug'

# Main application class that handles routing and server initialization
class App < Router
  r = Router.new

  r.get '/' do
    erb(:"views/index")
  end

  r.get '/fruits' do
    erb(:"views/fruits")
  end

  def self.run
    server = HTTPServer.new(4567)
    server.start
  end
end

App.run
