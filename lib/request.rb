# frozen_string_literal: true

class Request
  attr_reader :method, :resource, :headers, :version, :params, :path

  def initialize(request_string)
    header_section, body_section = request_string.split("\n\n", 2)
    lines = header_section.split("\n")

    @headers = {}
    @params = {}
    parse_first_line(line)

    if query_string
      parse_params(params_string, query_string)
    end
  end

    def parse_first_line(line)
      @method, @resource, @version = line.split(' ')
      @method = @method.downcase.to_sym
      return @method, @resource, @version
    end

    def parse_params(params_string, query_string)
      params_string = query_string.split('&')
      params_string.map do |param|
        key, value = param.split('=')
        @params[key] = value
      end
    end

    lines.map do |line|
      if line == lines[0]
        
        @path = @resource.split('?')[0]
        query_string = @resource.split('?')[1]

      else
        @headers[line.split(': ')[0]] = line.split(': ')[1]
      end

      next unless body_section

      def post_params(body_section)
        body_section.split('&').map do |param|
          key, value = param.split('=')
          @params[key] = value
        end
      end

    end
  end
end
