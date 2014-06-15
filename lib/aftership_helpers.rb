module AftershipHelpers
  def process_shipment
    aftership = AftershipService.new(@payload)
    aftership.update_or_create!
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
end