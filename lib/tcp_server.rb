# frozen_string_literal: true

require 'socket'
require 'debug'
require 'erb'
require_relative 'request'
require_relative 'router'
require_relative 'response'
require_relative 'sinatra_clone'

# TCP server implementation that handles HTTP requests, routes them, and returns responses
class HTTPServer
  def initialize(port, router)
    @port = port
    @router = router
  end

  # A hash of all required mime tyoes and thair content type
  MIME_TYPES = {
    'html' => 'text/html',
    'css' => 'text/css',
    'js' => 'application/javascript',
    'jpg' => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'svg' => 'image/svg+xml',
    'ico' => 'image/x-icon'
  }.freeze

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    while (session = server.accept)
      handle_request(session)
      session.close
    end
  end

  private

  def handle_request(session)
    request = parse_request(session)
    response = process_request(request)
    session.print response.to_s
  end

  def parse_request(session)
    data = read_headers(session)
    content_length = data[/Content-Length:\s*(\d+)/i, 1].to_i

    data += "\n" + session.gets(content_length) if content_length

    Request.new(data)
  end

  def read_headers(session)
    data = ''
    while (line = session.gets) && line !~ /^\s*$/
      data += line
    end
    data
  end

  def process_request(request)
    route = @router.match_route(request)

    if route
      handle_route(route, request)
    elsif File.exist?("public#{request.resource}") && request.resource.include?('.')
      get_mime_type(request.resource)
    else
      Response.new(404, File.read('views/404.erb'), { 'Content-type' => 'text/html' })
    end
  end

  def handle_route(route, request)
    route_block = route[:block].call(request)

    if route_block.class != String && route_block[:status] && route_block[:status] == 302
      Response.new(route_block[:status], route_block[:body], route_block[:headers])
    else
      Response.new(200, route_block, { 'Content-type' => 'text/html' })
    end
  end

  def get_mime_type(path)
    file_path = "public#{path}"
    file_content = File.binread(file_path)
    extension = File.extname(file_path).delete('.')
    file_content_type = MIME_TYPES[extension] || 'application/octet-stream'

    Response.new(200, file_content, { 'Content-type' => file_content_type })
  end
end
