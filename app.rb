# frozen_string_literal: true

require_relative 'lib/sinatra_clone'

# Main application class that handles routing and server initialization
class App < SinatraClone
  r.get '/' do
    erb :"views/index"
  end

  r.get '/add/:num1/:num2' do |request|
    @num1 = request.params[:num1].to_i
    @num2 = request.params[:num2].to_i
    @sum = @num1 + @num2

    erb :"views/dynamic_routes/add"
  end

  r.post '/login' do |request|
    redirect "/profile/#{request.params[:username]}/#{request.params[:password]}"
  end

  r.get '/profile/:username/:password' do |request|
    @username = request.params[:username]
    @password = request.params[:password]

    erb :"views/dynamic_routes/profile"
  end
end

App.run
