# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/response'
require 'debug'

describe 'Router' do
  it 'cheks if the response is correct' do
    response = Response.new(200, '<html><body><h1>Hej Världen</h1></body></html>')
    _(response.to_s).must_equal "HTTP/1.1 200 OK\r\n\r\n<html><body><h1>Hej Världen</h1></body></html>"
  end

  it 'cheks if the page is not found' do
    response = Response.new(404, '<html><body><h1>Hej Världen</h1></body></html>')
    _(response.to_s).must_equal "HTTP/1.1 404 Not Found\r\n\r\n<html><body><h1>Hej Världen</h1></body></html>"
  end
end
