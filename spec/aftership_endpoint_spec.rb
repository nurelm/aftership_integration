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

  context "POST :add_shipment" do
    it "calls update_or_create shipment" do
      receive_shipment_updater
      post '/add_shipment', shipment_payload.to_json, auth
      expect(last_response.status).to eq 200
    end

    it "returns success" do
      stub_detect_courier(couriers.to_json)
      stub_get_tracking(tracking_not_exist.to_json)
      stub_post_tracking(tracking_posted_successfully.to_json)

      post '/add_shipment', shipment_payload.to_json, auth
      expect(last_response.status).to eq 200
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
      stub_get_trackings(trackings.to_json)

      post '/get_trackings', trackings_payload.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  def receive_shipment_updater
    service = double('AftershipService')
    expect(service).to receive(:post!).and_return(tracking_posted_successfully["data"]["tracking"])
    expect(AftershipService).to receive(:new).with(shipment_payload, shipment_payload["parameters"]).and_return(service)
  end
end
