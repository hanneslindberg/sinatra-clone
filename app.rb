# frozen_string_literal: true

require_relative 'lib/tcp_server'
require_relative 'lib/router'
require 'debug'

class Grillkorv
  def self.r
    @r ||= Router.new
  end

  def self.erb(html_file)
    file = html_file.to_s + '.erb'
    ERB.new(File.read(file)).result(binding)
  end

  def self.run
    server = HTTPServer.new(4567, @r)
    server.start
  end
end

# Main application class that handles routing and server initialization

class App < Grillkorv
  r.get '/' do
    erb(:"views/index")
  end

  r.get '/fruits' do
    erb(:"views/fruits")
  end
end

App.run
