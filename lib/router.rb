# frozen_string_literal: true

require_relative 'request'
require_relative 'response'

# Handles routing of HTTP requests to their corresponding handlers
class Router
  # Initializes a new Router instance
  #
  # @return [void]
  def initialize
    @routes = []
  end

  # Adds a new route to the router
  #
  # @param method [Symbol] the HTTP method (:get, :post, etc.)
  # @param path [String] the route path pattern
  # @param block [Proc] the handler for the route
  # @return [void]
  def add_route(method, path, &block)
    @routes << { method: method, path: path, block: block }
  end

  # Matches a request to a registered route
  #
  # @param request [Request] the request to match
  # @return [Hash, nil] the matched route or nil if no match
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

  # Adds a GET route
  #
  # @param path [String] the route path pattern
  # @param block [Proc] the handler for the route
  # @return [void]
  def get(path, &block)
    add_route(:get, path, &block)
  end

  # Adds a POST route
  #
  # @param path [String] the route path pattern
  # @param block [Proc] the handler for the route
  # @return [void]
  def post(path, &block)
    add_route(:post, path, &block)
  end

  # Converts a route pattern to a regular expression
  #
  # @param route_path [String] the route pattern
  # @return [Regexp] the regular expression for matching
  def regex_to_route_path(route_path)
    Regexp.new("^#{route_path.gsub(/:\w+/, '(\w+)')}$")
  end

  # Extracts parameters from a matched path
  #
  # @param route_path [String] the route pattern
  # @param request_path [String] the actual request path
  # @return [Hash] the extracted parameters
  def extract_params(route_path, request_path)
    regex = regex_to_route_path(route_path)
    match_data = request_path.match(regex)
    return {} unless match_data

    param_names = route_path.scan(/:(\w+)/).flatten.map(&:to_sym)
    param_values = match_data.captures
    Hash[param_names.zip(param_values)]
  end
end
