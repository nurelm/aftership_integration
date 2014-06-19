class AftershipService
  def initialize(payload, config)
    @payload, @config = payload, config
    authenticate
  end

  def update_or_create!
    @courier_slug = check_tracking_number!
    response = AfterShip::V3::Tracking.get(@courier_slug, tracking_number)
    if response['meta']['code'] == 404
      create
    else
      update
    end
  end

  def get_tracking!
    @courier_slug = check_tracking_number!
    @response = AfterShip::V3::Tracking.get(@courier_slug, tracking_number)
    process_response
  end

  private

  def process_response
    if [200, 201].include? @response['meta']['code']
      @response['data']['tracking']
    else
      raise BadResponseError.new(@response)
    end
  end

  def update
    @response = AfterShip::V3::Tracking.update(@courier_slug, tracking_number, params)
    process_response
  end

  def create
    @response = AfterShip::V3::Tracking.create(tracking_number, params)
    process_response
  end

  def shipment
    @payload['shipment']
  end

  def tracking_number
    shipment['tracking']
  end

  def check_tracking_number!
    response = AfterShip::V3::Courier.detect(tracking_number)
    if response['meta']['code'] == 200
      courier = response['data']['couriers'].first
      return courier['slug'] if courier && courier['slug']
    end
    raise BadTrackingNumberError
  end

  def authenticate
    AfterShip.api_key = api_key
  end

  def api_key
    @config['aftership_api_key']
  end

  def params
    {
      'emails'        => [shipment['email']],
      'smses'         => [shipment['shipping_address']['phone']],
      'order_id'      => shipment['order_id'],
      'title'         => shipment['items'].map{|item| item['name'] }.join(', '),
      'customer_name' => [shipment['shipping_address']['firstname'], shipment['shipping_address']['lastname']].join(', '),
      'custom_fields' => {
        'items'           => shipment['items'].map{|item| item['name'] }.join(', '),
        'firstname'       => shipment['shipping_address']['firstname'],
        'lastname'        => shipment['shipping_address']['lastname'],
        'address1'        => shipment['shipping_address']['address1'],
        'address2'        => shipment['shipping_address']['address2'],
        'zipcode'         => shipment['shipping_address']['zipcode'],
        'city'            => shipment['shipping_address']['city'],
        'state'           => shipment['shipping_address']['state'],
        'country'         => shipment['shipping_address']['country'],
        'phone'           => shipment['shipping_address']['phone'],
        'cost'            => shipment['cost'],
        'stock_location'  => shipment['stock_location'],
        'shipping_method' => shipment['shipping_method'],
        'shipment_id'     => shipment['id'],
        'status'          => shipment['status']
      }
    }
  end
end