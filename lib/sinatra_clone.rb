# frozen_string_literal: true

require_relative 'tcp_server'
require_relative 'router'

class SinatraClone
  def self.r
    @r ||= Router.new(Response)
  end

  def self.erb(html_file)
    file = html_file.to_s + '.erb'
    ERB.new(File.read(file)).result(binding)
  end

  def self.run
    server = HTTPServer.new(4567, @r)
    server.start
  end

  def self.redirect(path)
    hash = {}
    hash[:status] = 302
    hash[:body] = ''
    hash[:headers] = { 'Location' => path }
  end
end
