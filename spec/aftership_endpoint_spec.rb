require 'spec_helper'

describe AftershipEndpoint do
  let(:shipment_payload) { FactoryRequests.shipment }
  let(:couriers) { FactoryResponses.couriers }
  let(:tracking_not_exist) { FactoryResponses.tracking_not_exist }
  let(:tracking_posted_successfully) { FactoryResponses.tracking_posted_successfully }
  let(:tracking) { FactoryResponses.tracking }

  context "POST :add_shipment" do
    it "calls update_or_create shipment" do
      receive_shipment_updater
      post '/add_shipment', shipment_payload.to_json
      expect(last_response.status).to eq 201
    end

    it "returns success" do
      stub_detect_courier(couriers.to_json)
      stub_get_tracking(tracking_not_exist.to_json)
      stub_post_tracking(tracking_posted_successfully.to_json)
      post '/add_shipment', shipment_payload.to_json
      expect(last_response.status).to eq 201
    end
  end

  context "POST :update_shipment" do
    it "calls update_or_create shipment" do
      receive_shipment_updater
      post '/update_shipment', shipment_payload.to_json
      expect(last_response.status).to eq 200
    end

    it "returns success" do
      stub_detect_courier(couriers.to_json)
      stub_get_tracking(tracking.to_json)
      stub_put_tracking(tracking_posted_successfully.to_json)
      post '/update_shipment', shipment_payload.to_json
      expect(last_response.status).to eq 200
    end
  end

  context "POST :get_tracking" do
    it "calls get_tracking" do
      service = double('AftershipService')
      expect(service).to receive(:get_tracking!).and_return(tracking["data"]["tracking"])
      expect(AftershipService).to receive(:new).with(shipment_payload, shipment_payload["parameters"]).and_return(service)
      post '/get_tracking', shipment_payload.to_json
      expect(last_response.status).to eq 200
    end

    it "returns success" do
      stub_detect_courier(couriers.to_json)
      stub_get_tracking(tracking.to_json)
      post '/get_tracking', shipment_payload.to_json
      expect(last_response.status).to eq 200
    end
  end

  def receive_shipment_updater
    service = double('AftershipService')
    expect(service).to receive(:update_or_create!).and_return(tracking_posted_successfully["data"]["tracking"])
    expect(AftershipService).to receive(:new).with(shipment_payload, shipment_payload["parameters"]).and_return(service)
  end
end