class PostShipment < AftershipService
  def post!
    @courier_slug = check_tracking_number!
    response = AfterShip::V3::Tracking.get(@courier_slug, tracking_number)
    if response['meta']['code'] == 404
      create
    else
      update
    end
  end

  private

  def update
    @response = AfterShip::V3::Tracking.update(@courier_slug, tracking_number, params)
    process_response
  end

  def create
    @response = AfterShip::V3::Tracking.create(tracking_number, params)
    process_response
  end

  def process_response
    if [200, 201].include? @response['meta']['code']
      @response['data']['tracking']
    else
      raise BadResponseError.new(@response)
    end
  end

  def params
    {
      'title'         => shipment['order_id'],
      'smses'         => [shipment['shipping_address']['phone']],
      'emails'        => [shipment['email']],
      'order_id'      => shipment['order_id'],
      'customer_name' => [shipment['shipping_address']['firstname'], shipment['shipping_address']['lastname']].join(', '),
      'custom_fields' => shipment
    }
  end
end