require 'spec_helper'

describe AftershipEndpoint do
  let(:shipment_payload) { FactoryRequests.shipment }
  let(:trackings_payload) { FactoryRequests.trackings }
  let(:couriers) { FactoryResponses.couriers }
  let(:tracking_not_exist) { FactoryResponses.tracking_not_exist }
  let(:tracking_posted_successfully) { FactoryResponses.tracking_posted_successfully }
  let(:tracking) { FactoryResponses.tracking }
  let(:trackings) { FactoryResponses.trackings }
  let(:trackings_result) { Factory.trackings_to_shipments_result }

  let(:config) do
    {
      parameters: {
        aftership_api_key: ENV['AFTERSHIP_APIKEY']
      }
    }
  end

  context "POST :add_shipment" do
    it "calls update_or_create shipment" do
      receive_shipment_updater
      post '/add_shipment', shipment_payload.to_json, auth
      expect(last_response.status).to eq 200
    end

    it "returns success" do
      message = {
        shipment: {
          id: '123',
          tracking: '9261290100142920399157',
          shipping_address: {
            firstname: 'Spree',
            lastname: 'Commerce',
            phone: '558699894125'
          }
        }
      }.merge! config

      VCR.use_cassette "add_shipmentv4" do
        post '/add_shipment', message.to_json, auth
        expect(json_response[:summary]).to match 'Successfully sent shipment to AfterShip'
        expect(last_response.status).to eq 200
      end
    end

    it "returns friendly message on missing tracking number" do
      shipment_payload['shipment']['tracking'] = ""
      post '/add_shipment', shipment_payload.to_json, auth

      expect(last_response.status).to eq 500
      expect(json_response[:summary]).to match "provide a tracking number via shipment.tracking"
    end
  end

  context "POST :update_shipment" do
    it "calls update_or_create shipment" do
      receive_shipment_updater

      post '/update_shipment', shipment_payload.to_json, auth
      expect(last_response.status).to eq 200
    end

    it "returns success" do
      stub_detect_courier(couriers.to_json)
      stub_get_tracking(tracking.to_json)
      stub_put_tracking(tracking_posted_successfully.to_json)

      post '/update_shipment', shipment_payload.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  context "GET :get_trackings" do
    it "calls get!" do
      service = double('GetTrackings')
      expect(service).to receive(:get!).and_return(trackings_result)
      expect(GetTrackings).to receive(:new).with(trackings_payload, trackings_payload["parameters"]).and_return(service)

      post '/get_trackings', trackings_payload.to_json, auth
      expect(last_response.status).to eq 200
    end

    it "returns success" do
      VCR.use_cassette "get_trackingsv4" do
        post '/get_trackings', config.to_json, auth
        expect(json_response[:summary]).to match /Receive/
        expect(last_response.status).to eq 200
      end
    end
  end

  def receive_shipment_updater
    service = double('AftershipService')
    expect(service).to receive(:post!).and_return(tracking_posted_successfully["data"]["tracking"])
    expect(AftershipService).to receive(:new).with(shipment_payload, shipment_payload["parameters"]).and_return(service)
  end
end
