module Fixtures
  def load_fixture(name)
    IO.read(File.join(File.dirname(__FILE__), '..', 'fixtures', "#{name}.json"))
  end
end

module Factory
  class << self
    def trackings_to_shipments_result
      shipment = {
        id: FactoryRequests.shipment['shipment']['id'], 
        status: FactoryResponses.tracking['data']['tracking']['tag'].downcase,
        checkpoints: FactoryResponses.tracking['data']['tracking']['checkpoints']
      }
      [shipment]
    end

    def shipment_to_tracking_result
      tracking = FactoryResponses.tracking['data']['tracking']
      {
        'title'         => tracking['order_id'],
        'smses'         => tracking['smses'],
        'emails'        => tracking['emails'],
        'order_id'      => tracking['order_id'],
        'customer_name' => tracking['customer_name'],
        'custom_fields' => tracking['custom_fields']
      }
    end
  end
end

module FactoryRequests
  extend Fixtures

  class << self
    def shipment
      JSON.parse(load_fixture('shipment_request'))
    end
  
    def trackings
      JSON.parse(load_fixture('get_trackings_request'))
    end
  end
end

module FactoryResponses
  extend Fixtures

  class << self
    def couriers
      JSON.parse(load_fixture('couriers_response'))
    end

    def tracking_not_exist
      JSON.parse(load_fixture('tracking_not_exist_response'))
    end

    def tracking
      JSON.parse(load_fixture('tracking_response'))
    end

    def tracking_posted_successfully
      JSON.parse(load_fixture('post_tracking_success_response'))
    end

    def trackings
      response = JSON.parse(load_fixture('trackings_response'))
      tracking_response = tracking
      response['data']['trackings'] = [tracking_response['data']['tracking']]
      response
    end
  end
end
