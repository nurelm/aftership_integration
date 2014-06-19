require 'spec_helper'

describe AftershipService do
  let(:shipment_payload) { FactoryRequests.shipment }
  let(:couriers) { FactoryResponses.couriers }
  let(:tracking) { FactoryResponses.tracking }
  let(:tracking_not_exist) { FactoryResponses.tracking_not_exist }
  let(:tracking_posted_successfully) { FactoryResponses.tracking_posted_successfully }
  let(:aftership_service) { AftershipService.new(shipment_payload, shipment_payload["parameters"]) }

  context "#new" do
    it "inits AfterShip API key" do 
      expect(AfterShip).to receive(:api_key=)
      aftership_service
    end
  end

  context "#update_or_create!" do
    before do
      stub_detect_courier(couriers.to_json)
    end

    it "creates tracking" do
      stub_get_tracking(tracking_not_exist.to_json)
      expect(aftership_service).to receive(:create)
      aftership_service.update_or_create!
    end

    it "updates tracking" do
      stub_get_tracking(tracking.to_json)
      expect(aftership_service).to receive(:update)
      aftership_service.update_or_create!
    end
  end

  context "#get_tracking!" do
    it "returns tracking" do
      stub_detect_courier(couriers.to_json)
      stub_get_tracking(tracking.to_json)
      expect(aftership_service.get_tracking!).to eq(tracking['data']['tracking'])
    end
  end

  context "#process_response" do
    it "returns tracking on code 200" do
      aftership_service.instance_variable_set(:@response, {'meta' => {'code' => 200}, 'data' => {'tracking' => 'tracking'}})
      expect(aftership_service.send(:process_response)).to eq('tracking')
    end

    it "returns tracking on code 201" do
      aftership_service.instance_variable_set(:@response, {'meta' => {'code' => 201}, 'data' => {'tracking' => 'tracking'}})
      expect(aftership_service.send(:process_response)).to eq('tracking')
    end

    it "raises BadResponseError exception" do
      aftership_service.instance_variable_set(:@response, {'meta' => {'code' => 404, 'error_type' => 'Not found', 'error_message' => 'Tracking not found'}})
      expect{aftership_service.send(:process_response)}.to raise_error(BadResponseError)
    end
  end

  context "#create" do
    it "sends process_response" do
      stub_post_tracking(tracking_posted_successfully.to_json)
      expect(aftership_service).to receive(:process_response)
      aftership_service.send(:create)
    end
  end

  context "#update" do
    it "sends process_response" do
      stub_put_tracking(tracking_posted_successfully.to_json)
      aftership_service.instance_variable_set(:@courier_slug, 'dhl')
      expect(aftership_service).to receive(:process_response)
      aftership_service.send(:update)
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

  context "#params" do
    it "returns shipment data" do
      shipment = shipment_payload['shipment']
      expect(aftership_service.send(:params)).to eq({
        'emails'        => [shipment['email']],
        'smses'         => [shipment['shipping_address']['phone']],
        'order_id'      => shipment['order_id'],
        'title'         => shipment['items'].map{|item| item['name'] }.join(', '),
        'customer_name' => [shipment['shipping_address']['firstname'], shipment['shipping_address']['lastname']].join(', '),
        'custom_fields' => {
          'items'           => shipment['items'].map{|item| item['name'] }.join(', '),
          'firstname'       => shipment['shipping_address']['firstname'],
          'lastname'        => shipment['shipping_address']['lastname'],
          'address1'        => shipment['shipping_address']['address1'],
          'address2'        => shipment['shipping_address']['address2'],
          'zipcode'         => shipment['shipping_address']['zipcode'],
          'city'            => shipment['shipping_address']['city'],
          'state'           => shipment['shipping_address']['state'],
          'country'         => shipment['shipping_address']['country'],
          'phone'           => shipment['shipping_address']['phone'],
          'cost'            => shipment['cost'],
          'stock_location'  => shipment['stock_location'],
          'shipping_method' => shipment['shipping_method'],
          'shipment_id'     => shipment['id'],
          'status'          => shipment['status']
        }
      })
    end
  end
end