# frozen_string_literal: true

require_relative 'tcp_server'
require_relative 'router'

# A lightweight web framework inspired by Sinatra, handling HTTP requests and routing
class SinatraClone
  # Returns or initializes the router instance
  #
  # @return [Router] the router instance for handling routes
  def self.r
    @r ||= Router.new
  end

  # Renders an ERB template file
  #
  # @param html_file [String, Symbol] the name of the ERB template to render
  # @return [String] the rendered HTML content
  def self.erb(html_file)
    file = html_file.to_s + '.erb'
    ERB.new(File.read(file)).result(binding)
  end

  # Starts the HTTP server on port 4567
  #
  # @return [void]
  def self.run
    server = HTTPServer.new(4567, @r)
    server.start
  end

  # Creates a redirect response
  #
  # @param path [String] the path to redirect to
  # @return [Hash] hash containing status, body, and headers for redirect
  def self.redirect(path)
    hash = {}
    hash[:status] = 302
    hash[:body] = ''
    hash[:headers] = { 'Location' => path }
    hash
  end
end
