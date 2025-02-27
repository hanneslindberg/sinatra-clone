# frozen_string_literal: true

require_relative 'lib/sinatra_clone'

# Main application class that handles routing and server initialization
class App < SinatraClone
  r.get '/' do
    erb :"views/index"
  end

  r.get '/fruits' do
    erb :"views/fruits"
  end

  r.get '/film' do
    erb :"views/film"
  end

  r.get '/add/:num1/:num2' do | request |
    num1 = request.params[:num1].to_i
    num2 = request.params[:num2].to_i
    @sum = num1 + num2
    puts @sum

    erb :"views/add"
  end
end

App.run
