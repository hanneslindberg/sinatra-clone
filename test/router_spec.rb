# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative 'spec_helper'
require_relative '../lib/request'
require_relative '../lib/router'
require 'debug'

describe 'Router' do # rubocop:disable Metrics/BlockLength
  before do
    @router = Router.new
  end

  it 'correctly matches routes based on method and path' do
    @router.add_route(:get, '/madremia') { 'Madremia route' }
    @router.add_route(:post, '/login') { 'Login route' }

    get_request = Request.new(File.read('test/example_requests/get-example.request.txt'))
    post_request = Request.new(File.read('test/example_requests/post-login.request.txt'))

    matched_route = @router.match_route(get_request)
    _(matched_route[:method]).must_equal :get
    _(matched_route[:path]).must_equal '/madremia'

    matched_route = @router.match_route(post_request)
    _(matched_route[:method]).must_equal :post
    _(matched_route[:path]).must_equal '/login'
  end

  it 'returns nil for unmatched method' do
    @router.add_route(:get, '/notfound') { 'Madremia route' }
    unmatched_request = Request.new("POST /notfound HTTP/1.1\r\nHost: example.com\r\n\r\n")

    matched_route = @router.match_route(unmatched_request)
    _(matched_route).must_equal nil
  end

  it 'returns nil for unmatched path' do
    @router.add_route(:post, '/mango') { 'Madremia route' }
    unmatched_request = Request.new("POST /notfound HTTP/1.1\r\nHost: example.com\r\n\r\n")

    matched_route = @router.match_route(unmatched_request)
    _(matched_route).must_equal nil
  end

  it 'matches routes regardless of query parameters' do
    @router.add_route(:get, '/fruits') { 'Fruits route' }

    request_with_query = Request.new("GET /fruits?type=apples HTTP/1.1\r\nHost: example.com\r\n\r\n")
    matched_route = @router.match_route(request_with_query)
    _(matched_route[:method]).must_equal :get
    _(matched_route[:path]).must_equal '/fruits'
  end
end
