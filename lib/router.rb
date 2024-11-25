require_relative 'request'

class Router
  def add_route(method, path, &block)
    @routes = []
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
