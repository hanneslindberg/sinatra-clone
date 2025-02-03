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
end
