module AftershipHelpers
  def process_shipment
    aftership = AftershipService.new(@payload, @config)
    @tracking = aftership.update_or_create!
    add_shipment_object
  end

  def process_request
    begin
      yield
    rescue AftershipError => e
      result e.code, e.message
    rescue Exception => e
      result 500, 'Sorry, something went wrong.'
    end
  end

  def add_shipment_object
    shipment = @payload[:shipment]
    shipment[:checkpoints] = @tracking['checkpoints']
    add_object :shipment, shipment
  end
end