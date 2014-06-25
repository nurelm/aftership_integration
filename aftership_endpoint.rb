# Sinatra
require 'sinatra'

# Hash fix
require 'active_support/core_ext/hash'

# Spree endpoint
require 'endpoint_base'

# Aftership API client
require 'aftership'

# Aftership endpoint helpers
require './lib/aftership_helpers'
require './lib/aftership_service'
require './lib/fields'
require './lib/post_shipment'
require './lib/get_trackings'

# Errors
require './lib/errors/aftership_error'
require './lib/errors/bad_response_error'
require './lib/errors/bad_tracking_number_error'

class AftershipEndpoint < EndpointBase::Sinatra::Base
  endpoint_key ENV["ENDPOINT_KEY"]
  helpers AftershipHelpers
  set :logging, true

  post '/add_shipment' do
    process_request do
      post_shipment
      result 200, 'Successfully sent shipment to AfterShip.'
    end
  end

  post '/update_shipment' do
    process_request do
      post_shipment
      result 200, 'Successfully updated shipment to AfterShip.'
    end
  end

  post '/get_trackings' do
    process_request do
      get_trackings = GetTrackings.new(@payload, @config)
      @shipments = get_trackings.get!
      @shipments.each do |shipment|
        add_object :shipment, shipment.deep_symbolize_keys
      end
      result 200, 'Successfully updated trackings from AfterShip.'
    end
  end
end