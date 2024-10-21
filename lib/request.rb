class Request
  attr_reader :method, :resource

  def initialize(request_string)
    lines = request_string.split("\n")
    @method = lines[0].split(" ")[0].downcase.to_sym

    
    lines.map { |line| 
        if line != lines[0]
          @header = line.split(" ")[0]
        end
      }

    p header
    
    @resource = "/"
  end
end