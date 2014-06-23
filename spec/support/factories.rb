module Fixtures
  def load_fixture(name)
    IO.read(File.join(File.dirname(__FILE__), '..', 'fixtures', "#{name}.json"))
  end
end

module FactoryRequests
  extend Fixtures

  class << self
    def shipment
      JSON.parse(load_fixture('shipment_request'))
    end
  end

  class << self
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
      JSON.parse(load_fixture('trackings_response'))
    end
  end
end