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
    unless tracking_number.present?
      raise AftershipError, "You need to provide a tracking number via shipment.tracking"
    end

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

  # Current status of tracking. Values include:
  #
  #   Pending, InTransit, OutForDelivery, AttemptFail, Delivered, Exception, Expired
  #
  # Use comma for multiple values.
  def tracking_tags
    @config['aftership_tracking_tag']
  end

  # Maps to AfterShip created_at_min:
  #
  #   Start date and time of trackings created. AfterShip only stores data of 90 days.
  #   (Defaults: 30 days ago, Example: 2013-03-15T16:41:56+08:00)
  #
  def tracking_days
    if since = @config['aftership_tracking_days']
      since.to_i.days.ago.utc
    else
      10.days.ago.utc
    end
  end
end
