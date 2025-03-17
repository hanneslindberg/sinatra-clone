# frozen_string_literal: true

require_relative 'request'
require_relative 'response'
require 'debug'

# Handles routing of HTTP requests to their corresponding handlers
class Router
  def initialize(response)
    @response = response
    @routes = []
  end

  def add_route(method, path, &block)
    @routes << { method: method, path: path, block: block }
  end

  def match_route(request)
    base_path = request.resource.split('?').first

    request_route = @routes.find do |route|
      route[:method] == request.method && regex_to_route_path(route[:path]).match(base_path)
    end

    return nil unless request_route

    params = extract_params(request_route[:path], base_path)

    request.params.merge!(params)
    request_route
  end

  def get(path, &block)
    add_route(:get, path, &block)
  end

  def post(path, &block)
    add_route(:post, path, &block)
  end

  def regex_to_route_path(route_path)
    Regexp.new("^#{route_path.gsub(/:\w+/, '(\w+)')}$")
  end

  def extract_params(route_path, request_path) # {:num1 => "1", :num2 => "2"}
    regex = regex_to_route_path(route_path)
    match_data = request_path.match(regex)

    return {} unless match_data

    param_names = route_path.scan(/:(\w+)/).flatten.map(&:to_sym)
    param_values = match_data.captures

    Hash[param_names.zip(param_values)]
  end

  def redirect(url)
    @response.new(302, '', { 'Location' => url })
  end
end
