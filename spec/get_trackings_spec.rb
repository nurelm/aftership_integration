require 'spec_helper'

describe GetTrackings do
  let(:trackings) { FactoryResponses.trackings }
  let(:trackings_payload) { FactoryRequests.trackings }
  let(:get_trackings) { GetTrackings.new(trackings_payload, trackings_payload["parameters"]) }

  context "#get!" do
    it "returns trackings" do
      stub_get_trackings(trackings.to_json)
      expect(get_trackings.get!).to eq(trackings['data']['trackings'])
    end
  end
end