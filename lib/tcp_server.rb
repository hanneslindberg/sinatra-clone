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
      data = ''
      while (line = session.gets) && line !~ /^\s*$/
        data += line
      end

      content_length = data[/Content-Length:\s*(\d+)/i, 1].to_i
      if content_length
        data += "\n"
        data += session.gets(content_length)
      end

      request = Request.new(data)
      route = @router.match_route(request)

      if route
        route_block = route[:block].call(request)

        response = if route_block.class != String && route_block[:status] && route_block[:status] == 302
                     Response.new(route_block[:status], route_block[:body], route_block[:headers])
                   else
                     Response.new(200, route_block, { 'Content-type' => 'text/html' })
                   end
      elsif File.exist?("public#{request.resource}") && request.resource.include?('.')
        response = get_mime_type(request.resource)
      else
        response = Response.new(404, File.read('views/404.erb'), { 'Content-type' => 'text/html' })
      end

      session.print response.to_s

      session.close
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
