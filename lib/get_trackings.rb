class GetTrackings < AftershipService
  def get!
    @response = AfterShip::V3::Tracking.get_multi()
    process_response
  end

  private

  def process_response
    if @response['meta']['code'] == 200
      @response['data']['trackings']
    else
      raise BadResponseError.new(@response)
    end
  end
end