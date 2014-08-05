class GetTrackings < AftershipService
  def get!
    @response = AfterShip::V3::Tracking.get_multi()
    process_response
  end

  private

  def process_response
    if @response['meta']['code'] == 200
      trackings_to_shipments(@response['data']['trackings'])
    else
      raise BadResponseError.new(@response)
    end
  end

  def trackings_to_shipments(trackings)
    trackings.inject([]) do |shipments, tracking|
      if tracking['custom_fields'] && tracking['custom_fields']['wombat_id']
        shipments << {
          id: tracking['custom_fields']['wombat_id'],
          status: tracking['tag'].downcase,
          checkpoints: tracking['checkpoints']
        }
      end

      shipments
    end
  end
end
