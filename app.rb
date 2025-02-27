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

  r.get '/add/:num1/:num2' do | request |
    num1 = request.params[:num1].to_i
    num2 = request.params[:num2].to_i
    @sum = num1 + num2
    puts "The sum is #{@sum}"

    erb :"views/dynamic_routes/add"
  end
  
  r.get '/fruits/:name' do | request |
    @name = request.params[:name]
    
    erb :"views/dynamic_routes/fruits"
  end

  r.post '/login' do | request |
    puts "Username is: #{request.params[:username]}"
    puts "Password is: #{request.params[:password]}"
  end
end

App.run
