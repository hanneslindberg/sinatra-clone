class Request
  attr_reader :method, :resource, :headers, :version, :params

  def initialize(request_string)
    header_section, body_section = request_string.split("\n\n", 2)
    lines = header_section.split("\n")
    
    @headers = {}
    @params = {}

    lines.map { |line| 
      if line == lines[0]
        @method, @resource, @version = line.split(" ")
        @method = @method.downcase.to_sym

        query_string = @resource.split("?")[1]

        if query_string
          params_string = query_string.split("&")
          params_string.map { |param| 
            key, value = param.split("=")
            @params[key] = value
          }
        end
      else
        @headers[line.split(": ")[0]] = line.split(": ")[1]
      end
      if body_section
        body_section.split("&").map { |param|
        key, value = param.split("=")
        @params[key] = value
        }
      end
    }
  end
end