# frozen_string_literal: true

# Represents an HTTP response with status, body, and headers
class Response
  # @return [Integer] the HTTP status code
  # @return [String] the response body content
  # @return [Hash] the HTTP headers
  attr_reader :status, :body, :headers

  # Initializes a new HTTP response
  #
  # @param status [Integer] the HTTP status code
  # @param body [String] the response body content
  # @param headers [Hash] the HTTP headers (default: {})
  # @return [void]
  def initialize(status, body, headers = {})
    @status = status
    @body = body
    @headers = headers
  end

  # Converts the response to a properly formatted HTTP response string
  #
  # @return [String] the formatted HTTP response
  def to_s
    response = "HTTP/1.1 #{@status} #{status_message}\r\n"
    header_section = @headers.map { |key, value| "#{key}: #{value}" }.join("\r\n")
    response += header_section
    response += "\r\n\r\n"
    response += @body
    response
  end

  # Returns the status message for a given HTTP status code
  #
  # @return [String] the HTTP status message
  def status_message
    case @status
    when 200 then 'OK'
    when 404 then 'Not Found'
    when 302 then 'Found'
    end
  end
end
