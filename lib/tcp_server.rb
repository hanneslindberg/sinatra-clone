# frozen_string_literal: true

require 'socket'
require 'debug'
require 'erb'
require_relative 'request'
require_relative 'router'
require_relative 'response'

class HTTPServer
  def initialize(port, router)
    @port = port
    @router = router
  end

  def start
    raise 'Router not set' unless @router

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

      puts '-' * 40
      # puts request.params
      puts 'RECEIVED REQUEST'
      puts '-' * 40
      puts data
      puts "\n"

      puts "Request resource: #{request.resource}"

      if route
        puts "Route: #{route}"
        puts '-' * 40
        response = Response.new(200, route[:block].call(request), { 'Content-type' => 'text/html' })
      elsif File.exist?("public#{request.resource}")
        response = get_mime_type(request.resource)
      else
        response = Response.new(404, File.read('views/page_not_found.erb'), { 'Content-type' => 'text/html' })
      end

      puts "Response: #{response.status}"

      # Nedanstående bör göras i er Response-klass
      session.print "HTTP/1.1 #{response.status}\r\n"
      session.print "Content-Type: #{response.headers['Content-type']}\r\n"
      session.print "\r\n"
      session.print response.body

      # session.print response.to_s
      session.close
    end
  end

  def get_mime_type(path)
    mime_types = {
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

    file_path = "public#{path}"
    file_content = File.binread(file_path)
    extension = File.extname(file_path).delete('.')
    file_content_type = mime_types[extension] || 'application/octet-stream'

    Response.new(200, file_content, file_content_type)
  end
end
