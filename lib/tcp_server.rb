require 'socket'
require_relative 'request'
require_relative 'router'

class HTTPServer
  def initialize(port)
    @port = port
  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    @router = Router.new

    @router.add_route(:get, '/') do
      erb(:"views/index")
    end

    while (session = server.accept)
      data = ''
      while (line = session.gets) && line !~ /^\s*$/
        data += line
      end
      puts 'RECEIVED REQUEST'
      puts '-' * 40
      puts data
      puts '-' * 40

      request = Request.new(data)
      route = @router.match_route(request)
      if route
        puts 'HTTP/1.1 200'
      else
        puts 'HTTP/1.1 404'
      end

      # Nedanstående bör göras i er Response-klass
      html = '<h1>Hello, World!</h1>'

      session.print "HTTP/1.1 200\r\n"
      session.print "Content-Type: text/html\r\n"
      session.print "\r\n"
      session.print html

      # session.print response.to_s
      puts ' i loopen'
      session.close
    end
  end
end

server = HTTPServer.new(4567)
server.start
