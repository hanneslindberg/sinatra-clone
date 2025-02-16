# frozen_string_literal: true

require_relative 'request'
require 'debug'

# Handles routing of HTTP requests to their corresponding handlers
class Router
  def initialize
    @routes = []
  end

  def add_route(method, path, &block)
    # Regular expressions
    @routes << { method: method, path: path, block: block }
  end

  def match_route(request)
    base_path = request.resource.split('?').first
    @routes.find { |route| route[:method] == request.method && route[:path] == base_path }
  end

  def get(path, &block)
    add_route(:get, path, &block)
  end

  def regex_to_route_path(route_path)
    Regexp.new("^#{route_path.gsub(/:\w+/, '(\w+)')}$") # /^\/frukter\/(\w+)\/(\w+)$/
  end

  def extract_params(route_path, request_path)
    regex = regex_to_route_path(route_path)
    match_data = request_path.match(regex)

    return {} unless match_data

    param_names = route_path.scan(/:(\w+)/).flatten.map(&:to_sym) # [:id, :name]
    param_values = match_data.captures

    Hash[param_names.zip(param_values)]
  end
end
