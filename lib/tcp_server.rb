# frozen_string_literal: true

require 'socket'
require 'debug'
require 'erb'
require_relative 'request'
require_relative 'router'
require_relative 'response'
require_relative 'sinatra_clone'

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

      # check if redirect is called
      if route 
        x = route[:block].call(request)
        
        if x.class != String && x[:status] && x[:status] == 302
          response = Response.new(x[:status], x[:body], x[:headers])
        else
          response = Response.new(200, route[:block].call(request), { 'Content-type' => 'text/html' })
        end
      elsif File.exist?("public#{request.resource}") && request.resource.include?('.')
        response = get_mime_type(request.resource)
      else
        response = Response.new(404, File.read('views/page_not_found.erb'), { 'Content-type' => 'text/html' })
      end

      session.print response.to_s

      puts '-' * 40

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

    Response.new(200, file_content, { 'Content-type' => file_content_type })
  end
end
