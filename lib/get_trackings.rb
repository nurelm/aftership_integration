class GetTrackings < AftershipService
  include Fields

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
    trackings.map do |tracking|
      shipment = {'shipping_address' => {}}
      fields = tracking['custom_fields']
      
      custom_fields.each do |field|
        shipment[field] = fields[field]
      end

      shipping_address_fields.each do |field|
        shipment['shipping_address'][field] = fields["shipping_address_#{field}"]
      end

      i = 0
      while fields["items_#{i}_product_id"].present? do
        shipment['items'] ||= []
        item = {}
        item_fields.each do |field|
          item[field] = fields["items_#{i}_#{field}"]
        end
        shipment['items'] << item
        i+=1
      end

      shipment['checkpoints'] = tracking['checkpoints']
      shipment
    end
  end
end