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
  # Initializes a new HTTP server
  #
  # @param port [Integer] the port number to listen on
  # @param router [Router] the router instance for handling routes
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

  # Starts the server and begins listening for connections
  #
  # @return [void]
  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    while (session = server.accept)
      handle_request(session)
      session.close
    end
  end

  private

  # Handles an individual HTTP request
  #
  # @param session [TCPSocket] the client connection
  # @return [void]
  def handle_request(session)
    request = parse_request(session)
    response = process_request(request)
    session.print response.to_s
  end

  # Parses the raw HTTP request
  #
  # @param session [TCPSocket] the client connection
  # @return [Request] the parsed request object
  def parse_request(session)
    data = read_headers(session)
    content_length = data[/Content-Length:\s*(\d+)/i, 1].to_i
    data += "\n" + session.gets(content_length) if content_length
    Request.new(data)
  end

  # Reads the HTTP headers from the connection
  #
  # @param session [TCPSocket] the client connection
  # @return [String] the raw header data
  def read_headers(session)
    data = ''
    while (line = session.gets) && line !~ /^\s*$/
      data += line
    end
    data
  end

  # Processes the request and generates a response
  #
  # @param request [Request] the parsed request object
  # @return [Response] the response object
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

  # Handles a matched route
  #
  # @param route [Hash] the matched route data
  # @param request [Request] the request object
  # @return [Response] the response object
  def handle_route(route, request)
    route_block = route[:block].call(request)

    if route_block.class != String && route_block[:status] && route_block[:status] == 302
      Response.new(route_block[:status], route_block[:body], route_block[:headers])
    else
      Response.new(200, route_block, { 'Content-type' => 'text/html' })
    end
  end

  # Handles static file requests with appropriate MIME types
  #
  # @param path [String] the requested file path
  # @return [Response] the response object with the file content
  def get_mime_type(path)
    file_path = "public#{path}"
    file_content = File.binread(file_path)
    extension = File.extname(file_path).delete('.')
    file_content_type = MIME_TYPES[extension] || 'application/octet-stream'
    Response.new(200, file_content, { 'Content-type' => file_content_type })
  end
end
