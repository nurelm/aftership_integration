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

  def params
    {
      'title' => "Order # #{shipment['order_id']}",
      'smses' => phone_numbers,
      'emails' => [shipment['email']],
      'order_id' => shipment['order_id'],
      'customer_name' => [shipment['shipping_address']['firstname'], shipment['shipping_address']['lastname']].join(' '),
      'custom_fields' => { 'wombat_id' => shipment['id'] }
    }
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

  def phone_numbers
    phone = shipment['shipping_address']['phone'].to_s
    if phone.start_with? "+"
      [phone]
    else
      [phone.insert(0, "+")]
    end
  end
end
