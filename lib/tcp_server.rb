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

      request = Request.new(data)
      puts 'RECEIVED REQUEST'
      puts '-' * 40
      puts data
      puts "\n"
      
      response = @router.match_route(request)
      puts "\n"
      puts "RESPONSE #{response.status}"
      puts '-' * 40
      session.print response

      # Nedanstående bör göras i er Response-klass
      # session.print "HTTP/1.1 #{status}\r\n"
      # session.print "Content-Type: text/html\r\n"
      # session.print "\r\n"
      # session.print html

      # session.print response.to_s
      session.close
    end
  end
end
