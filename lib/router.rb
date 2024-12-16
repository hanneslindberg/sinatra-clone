# frozen_string_literal: true

require_relative 'request'
require 'debug'

class Router
  def initialize
    @routes = []
  end

  def add_route(method, path, &block)
    @routes << { method: method, path: path, block: block }
  end

  def match_route(request)
    base_path = request.resource.split('?').first

    @routes.each do |route|
      next unless route[:method] == request.method
      return route if route[:path] == base_path
    end

    # @routes.find { |route| route[:method] == request.method && route[:path] == base_path }
  end
end

router = Router.new

router.add_route('GET', '/') { '<h1> HEJ </h1>' }
router.add_route('POST', '/banan') { '<h2> DÅ </h2>' }
