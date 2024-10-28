require_relative 'spec_helper'
require_relative '../lib/request'
require_relative '../lib/router'

describe 'Router' do
	let(:router) { Router.new }

	before do
		router.get('/fruits') { "finns" }    
	end

	it 'routes GET requests to the correct handler' do
		request_string = File.read('test/example_requests/get-fruits-with-filter.request.txt') 
		response = router.call(request_string)  
		_(response).must_equal "finns"
	end

	it 'returns 404 for non-existing routes' do
		request_string = File.read('test/example_requests/get-example.request.txt') 
		response = router.call(request_string)
		_(response).must_equal "finns inte"
	end
end