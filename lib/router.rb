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

  def regexp_to_route_path(route_path)
    Regexp.new("^#{route_path.gsub(/:\w+/, '(\w+)')}$") # /frukt/:id/:namn
  end

  def extract_params(route_path)
    route = regexp_to_route_path(route_path)
    id, namn = /:\w+/.match?(route).captures
  end
end
