class AftershipService
  def initialize(payload, config)
    @payload, @config = payload, config
    authenticate
  end

  private

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
    raise BadTrackingNumberError, "Was provided wrong or not supported Tracking Number."
  end

  def authenticate
    AfterShip.api_key = api_key
  end

  def api_key
    @config['aftership_api_key']
  end
end
