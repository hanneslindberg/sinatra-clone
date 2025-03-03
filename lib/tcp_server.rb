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
      puts '-' * 40
      puts 'RECEIVED REQUEST'
      puts '-' * 40
      puts data
      puts "\n"

      route = @router.match_route(request)

      puts "\n"
      puts "Route: #{route}"
      puts '-' * 40

      if route
        response = Response.new(200, route[:block].call(request), { 'Content-type' => 'text/html' })
      elsif 1 == 2 # finns filen i filsystemet
        file_path = '/img/film.jpeg'
        response = Response.new(200, filens_innehåll, filens_content_type)
      else
        response = Response.new(404, File.read('views/page_not_found.erb'), { 'Content-type' => 'text/html' })
      end

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
