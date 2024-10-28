require 'json'
require_relative '../lib/request'

class Router
	def initialize
		@routes = {}
	end

	def get(path, &block)
		@routes[[:get, path]] = block
	end

	def post(path, &block)
		@routes[[:post, path]] = block
	end

	def call(request_string)
		request = Request.new(request_string)
		key = [request.method, request.path]
		
		if @routes.key?(key)
			response = @routes[key].call
			response = "finns"
		else
			response = "finns inte"
		end

		response
	end

	def list_routes
    @routes.map { | (method, path), block|
			puts "#{method}; #{path}"
		}
  end
end

router = Router.new
router.get('/fruits') { "finns" }
router.post('/login') { "inloggad" }

router.list_routes