module AftershipHelpers
  def post_shipment
    shipment = PostShipment.new(@payload, @config)
    shipment.post!
  end

  def process_request
    begin
      yield
    rescue AftershipError => e
      result e.code, e.message
    end
  end
end