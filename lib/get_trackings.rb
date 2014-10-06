class GetTrackings < AftershipService
  def get!
    @response = AfterShip::V3::Tracking.get_multi params
    process_response
  end

  private

  def params
    hash = {}
    hash[:tag] = tracking_tags if tracking_tags.present?
    hash[:created_at_min] = tracking_days if tracking_days.present?
    hash
  end

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
          aftership_tracking: tracking.except('checkpoints'),
          checkpoints: tracking['checkpoints']
        }
      end

      shipments
    end
  end
end
