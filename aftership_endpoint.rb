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
      process_shipment
      result 201, 'Successfully sent shipment to AfterShip.'
    end
  end

  post '/update_shipment' do
    process_request do
      process_shipment
      result 200, 'Successfully updated shipment for AfterShip.'
    end
  end

  post '/get_tracking' do
    process_request do
      aftership = AftershipService.new(@payload)
      tracking = aftership.get_tracking!
      shipment = @payload[:shipment]
      shipment[:checkpoints] = tracking['checkpoints']
      add_object :shipment, shipment
      result 200, 'Successfully updated checkpoints from AfterShip.'
    end
  end
end