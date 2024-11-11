# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative 'spec_helper'
require_relative '../lib/request'

describe 'Request' do
  REQUEST_TEST_DATA = {
    'get-index.request.txt' => {
      method: :get,
      resource: '/',
      version: 'HTTP/1.1',
      headers: { 'Host' => 'developer.mozilla.org', 'Accept-Language' => 'fr' },
      params: {}
    },
    'post-login.request.txt' => {
      method: :post,
      resource: '/login',
      version: 'HTTP/1.1',
      headers: { 'Host' => 'foo.example', 'Content-Type' => 'application/x-www-form-urlencoded',
                 'Content-Length' => '39' },
      params: { 'username' => 'grillkorv', 'password' => 'verys3cret!' }
    },
    'get-fruits-with-filter.request.txt' => {
      method: :get,
      resource: '/fruits?type=bananas&minrating=4',
      version: 'HTTP/1.1',
      headers: { 'Host' => 'fruits.com', 'User-Agent' => 'ExampleBrowser/1.0', 'Accept-Encoding' => 'gzip, deflate',
                 'Accept' => '*/*' },
      params: { 'type' => 'bananas', 'minrating' => '4' }
    }
  }.freeze

  REQUEST_TEST_DATA.each do |file, expected_attributes|
    it "correctly parses request attributes from #{file}" do
      request = Request.new(File.read("test/example_requests/#{file}"))

      _(request.method).must_equal expected_attributes[:method]
      _(request.resource).must_equal expected_attributes[:resource]
      _(request.version).must_equal expected_attributes[:version]
      _(request.headers).must_equal expected_attributes[:headers]
      _(request.params).must_equal expected_attributes[:params]
    end
  end
end
