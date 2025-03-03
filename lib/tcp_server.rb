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

      # kolla om det finns content-length och method är post
      # data += session.gets(content_length)

      request = Request.new(data)
      route = @router.match_route(request)

      puts '-' * 40
      puts 'RECEIVED REQUEST'
      puts '-' * 40
      puts data
      puts "\n"

      puts "Request resource: #{request.resource}"

      if route
        puts "Route: #{route}"
        puts '-' * 40

        response = Response.new(200, route[:block].call(request), { 'Content-type' => 'text/html' })
      elsif File.file?("public#{request.resource}") # finns filen i filsystemet
        file_path = "public#{request.resource}"
        file_content = File.binread(file_path)
        file_content_type = case File.extname(file_path)
                            when '.jpeg', '.jpg' then 'image/jpeg'
                            when '.png' then 'image/png'
                            when '.gif' then 'image/gif'
                            else 'application/octet-stream'
                            end

        response = Response.new(200, file_content, file_content_type)
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
end
