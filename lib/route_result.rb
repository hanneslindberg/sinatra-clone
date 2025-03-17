module RouteResult
  def self.from(block, request)
    # skapa en hash med status etc
    # kör block.call

    Response.new(200, block.call(request))

    # Response(hash)
  end
end
