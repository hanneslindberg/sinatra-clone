# frozen_string_literal: true

# Parses and handles HTTP request data including method, headers, and parameters
class Request
  attr_reader :method, :resource, :headers, :version, :params, :path

  def initialize(request_string)
    header_section, body_section = request_string.split("\n\n", 2)
    lines = header_section.split("\n")
    @headers = {}
    @params = {}

    lines.map { |line| line == lines[0] ? parse_first_line(line) : parse_headers(line) }

    @path, query_string = @resource.include?('?') ? @resource.split('?', 2) : [@resource, nil]

    @resource.include?('?') ? parse_get_params(query_string) : @path = @resource

    parse_post_params(body_section) if body_section
  end

  def parse_first_line(line)
    @method, @resource, @version = line.split(' ')
    @method = @method.downcase.to_sym
    [@method, @resource, @version]
  end

  def parse_headers(line)
    @headers[line.split(': ')[0]] = line.split(': ')[1]
  end

  def parse_get_params(query_string)
    params_string = query_string.split('&')
    params_string.map do |param|
      key, value = param.split('=')
      @params[key] = value
    end
  end

  def parse_post_params(body_section)
    body_section.split('&').map do |param|
      key, value = param.split('=')
      @params[key.to_sym] = value
    end
  end
end
