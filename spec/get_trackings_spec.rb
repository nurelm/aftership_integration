require 'spec_helper'

describe GetTrackings do
  let(:trackings) { FactoryResponses.trackings }
  let(:trackings_payload) { FactoryRequests.trackings }
  let(:get_trackings) { GetTrackings.new(trackings_payload, trackings_payload["parameters"]) }
  let(:trackings_result) { Factory.trackings_to_shipments_result }

  context "#get!" do
    it "sends process_response" do
      stub_get_trackings(trackings.to_json)
      expect(get_trackings).to receive(:process_response)
      get_trackings.get!
    end
  end

  context "#process_response" do
    it "sends trackings_to_shipments" do
      get_trackings.instance_variable_set(:@response, {'meta' => {'code' => 200}, 'data' => {'trackings' => 'trackings'}})
      expect(get_trackings).to receive(:trackings_to_shipments).with('trackings')
      get_trackings.send(:process_response)
    end

    it "raise BadResponseError exaption" do
      get_trackings.instance_variable_set(:@response, {'meta' => {'code' => 404, 'error_type' => 'Not found', 'error_message' => 'Tracking not found'}})
      expect{get_trackings.send(:process_response)}.to raise_error(BadResponseError)
    end
  end

  context "#trackings_to_shipments" do
    it "returns shipments" do
      result = get_trackings.send(:trackings_to_shipments, trackings['data']['trackings'])
      expect(result).to eq(trackings_result)
    end
  end
end
