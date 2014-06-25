class PostShipment < AftershipService
  include Fields

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
    fields = {
      'title' => shipment['order_id'],
      'smses' => [shipment['shipping_address']['phone']],
      'emails' => [shipment['email']],
      'order_id' => shipment['order_id'],
      'customer_name' => [shipment['shipping_address']['firstname'], shipment['shipping_address']['lastname']].join(' '),
      'custom_fields' => {}
    }

    custom_fields.each do |field|
      fields['custom_fields'][field] = shipment[field]
    end
    
    shipping_address_fields.each do |field|
      fields['custom_fields']["shipping_address_#{field}"] = shipment['shipping_address'][field]
    end

    if shipment['items'].present?
      shipment['items'].each_with_index do |item, i|
        item_fields.each do |field|
          fields['custom_fields']["items_#{i}_#{field}"] = item[field]
        end
      end
    end

    fields
  end
end
