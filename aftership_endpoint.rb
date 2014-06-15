require 'sinatra'
require 'endpoint_base'
require 'aftership'

class AftershipEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  before do
    #authenticate_aftership
  end

  get '/test'
    'It works'
  end

  post '/add_shipment' do
    shipment = @config[:shipment]
    response = AfterShip::V3::Tracking.create(shipment[:tracking], shipment_params)
    if response['meta']['code'] == 201
      result 200, 'Successfully sent shipment to AfterShip'
    else
      error_result(response)
    end 
  end

  post '/get_shipments' do
    params = {}
    params[:created_at_min] = @config[:since] if @config[:since].present?
    response = AfterShip::V3::Tracking.get_multi(params)
    if response['meta']['code'] == 200
      response['data']['trackings'].each do |tracking|
        add_object :shipment, {
          id: tracking['custom_fields']['shipment_id']
          order_id: tracking['order_id']
          tracking: tracking['tracking_number']
        }
      end
      result 200, "Retrieved #{response['data']['count']} shipments from AfterShip"
    else
      error_result(response)
    end
  end

  post '/update_shipment' do
    if courier_slug
      response = AfterShip::V3::Tracking.update(courier_slug, shipment, shipment_params)
      if response['meta']['code'] == 200
        result 200, 'Shipment was successfully updated'
      else
        error_result(response)
      end
    end
  end

  post '/get_tracking' do
    AfterShip::V3::Tracking.get('ups', '1ZA6F598D992381375')
  end 

  private

  def courier_slug
    response = AfterShip::V3::Courier.detect(@config[:shipment])
    if response['meta']['code'] == 200
      courier = response['data']['couriers'].first
      courier['slug'] if courier
    else
      error_result(response)
    end
  end

  def tracking_number
    
  end

  def authenticate_aftership
    AfterShip.api_key = @config['aftership.api_key']
  end

  def shipment_params
    shipment = @config[:shipment]
    {
      'emails'        => [shipment[:email]],
      'smses'         => [shipment[:shipping_address][:phone]],
      'order_id'      => shipment[:order_id],
      'title'         => shipment[:items].map{|item| item[:name] }.join(', '),
      'customer_name' => [shipment[:shipping_address][:firstname], shipment[:shipping_address][:lastname]].join(', '),
      'custom_fields' => {
        'items'             => shipment[:items],
        'shipping_address'  => shipment[:shipping_address],
        'cost'              => shipment[:cost],
        'stock_location'    => shipment[:stock_location],
        'shipping_method'   => shipment[:shipping_method],
        'shipment_id'       => shipment[:id],
        'status'            => shipment[:status]
      }
    }
  end

  def error_result(response)
    result response['meta']['code'], "#{response['meta']['error_type']}: #{response['meta']['error_message']}"
  end
end