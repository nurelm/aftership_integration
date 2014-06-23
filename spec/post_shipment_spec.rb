require 'spec_helper'

describe PostShipment do
  let(:shipment_payload) { FactoryRequests.shipment }
  let(:couriers) { FactoryResponses.couriers }
  let(:tracking) { FactoryResponses.tracking }
  let(:tracking_not_exist) { FactoryResponses.tracking_not_exist }
  let(:tracking_posted_successfully) { FactoryResponses.tracking_posted_successfully }
  let(:post_shipment) { PostShipment.new(shipment_payload, shipment_payload["parameters"]) }

  context "#post!" do
    before do
      stub_detect_courier(couriers.to_json)
    end

    it "creates tracking" do
      stub_get_tracking(tracking_not_exist.to_json)
      expect(post_shipment).to receive(:create)
      post_shipment.post!
    end

    it "updates tracking" do
      stub_get_tracking(tracking.to_json)
      expect(post_shipment).to receive(:update)
      post_shipment.post!
    end
  end

  context "#create" do
    it "sends process_response" do
      stub_post_tracking(tracking_posted_successfully.to_json)
      expect(post_shipment).to receive(:process_response)
      post_shipment.send(:create)
    end
  end

  context "#update" do
    it "sends process_response" do
      stub_put_tracking(tracking_posted_successfully.to_json)
      post_shipment.instance_variable_set(:@courier_slug, 'dhl')
      expect(post_shipment).to receive(:process_response)
      post_shipment.send(:update)
    end
  end

  context "#process_response" do
    it "returns tracking on code 200" do
      post_shipment.instance_variable_set(:@response, {'meta' => {'code' => 200}, 'data' => {'tracking' => 'tracking'}})
      expect(post_shipment.send(:process_response)).to eq('tracking')
    end

    it "returns tracking on code 201" do
      post_shipment.instance_variable_set(:@response, {'meta' => {'code' => 201}, 'data' => {'tracking' => 'tracking'}})
      expect(post_shipment.send(:process_response)).to eq('tracking')
    end

    it "raises BadResponseError exception" do
      post_shipment.instance_variable_set(:@response, {'meta' => {'code' => 404, 'error_type' => 'Not found', 'error_message' => 'Tracking not found'}})
      expect{post_shipment.send(:process_response)}.to raise_error(BadResponseError)
    end
  end

  context "#params" do
    it "returns shipment data" do
      shipment = shipment_payload['shipment']
      expect(post_shipment.send(:params)).to eq({
        'title'         => shipment['order_id'],
        'smses'         => [shipment['shipping_address']['phone']],
        'emails'        => [shipment['email']],
        'order_id'      => shipment['order_id'],
        'customer_name' => [shipment['shipping_address']['firstname'], shipment['shipping_address']['lastname']].join(', '),
        'custom_fields' => shipment
      })
    end
  end
end