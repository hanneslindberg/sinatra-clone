class Response
  attr_reader :status, :body, :headers

  def initialize(status, body, headers = {})
    @status = status
    @body = body
    @headers = headers
  end

  # response ska innehålla en status ---> HTTP/1.1 200 OK
  # sedan headers ----------------------> Content-Type: text/html
  #                                       Content-Length: 123
  # därefter en tom linje --------------> "\r\n"
  # sedan bodyn -------------------- ---> <html> "Hello World!" <html/>

  def to_s
    response = "HTTP/1.1 #{@status} #{status_message}\r\n"
    header_section = @headers.map { |key, value| "#{key}: #{value}" }.join("\r\n")

    response += "#{header_section}\r\n#{@body}"
    puts "Response: #{response}"
    response
  end

  def status_message
    case @status
    when 200 then 'OK'
    when 404 then 'Not Found'
    when 302 then 'Found'
    end
  end
end
