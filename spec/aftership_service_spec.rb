require 'spec_helper'

describe AftershipService do
  let(:shipment_payload) { FactoryRequests.shipment }
  let(:couriers) { FactoryResponses.couriers }
  let(:tracking) { FactoryResponses.tracking }
  let(:aftership_service) { AftershipService.new(shipment_payload, shipment_payload["parameters"]) }

  context "#new" do
    it "inits AfterShip API key" do 
      expect(AfterShip).to receive(:api_key=)
      aftership_service
    end
  end

  context "#check_tracking_number!" do
    it "returns slug" do
      stub_detect_courier(couriers.to_json)
      expect(aftership_service.send(:check_tracking_number!)).to eq('dhl')
    end

    it "raises BadTrackingNumberError exception" do
      stub_detect_courier({'meta' => {'code' => 404}}.to_json)
      expect{aftership_service.send(:check_tracking_number!)}.to raise_error(BadTrackingNumberError)
    end
  end

  context "#shipment" do
    it "returns shipment from payload" do
      aftership_service.instance_variable_set(:@payload, shipment_payload)
      expect(aftership_service.send(:shipment)).to eq(shipment_payload['shipment'])
    end
  end

  context "#tracking_number" do
    it "returns shipment tracking number" do
      aftership_service.instance_variable_set(:@payload, shipment_payload)
      expect(aftership_service.send(:tracking_number)).to eq(shipment_payload['shipment']['tracking'])
    end
  end

  context "#api_key" do
    it "returns API key" do
      expect(aftership_service.send(:api_key)).to eq(shipment_payload['parameters']['aftership_api_key'])
    end
  end
end