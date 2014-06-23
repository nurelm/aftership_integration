module WebStubs
  def stub_detect_courier(body)
    stub_request(:get, "https://api.aftership.com/v3/couriers/detect/1Z19A2R70355535069").to_return(status: 200, body: body)
  end

  def stub_get_tracking(body)
    stub_request(:get, "https://api.aftership.com/v3/trackings/dhl/1Z19A2R70355535069").to_return(status: 200, body: body)
  end

  def stub_post_tracking(body)
    stub_request(:post, "https://api.aftership.com/v3/trackings").to_return(status: 200, body: body)
  end

  def stub_put_tracking(body)
    stub_request(:put, "https://api.aftership.com/v3/trackings/dhl/1Z19A2R70355535069").to_return(status: 200, body: body)
  end

  def stub_get_trackings(body)
    stub_request(:get, "https://api.aftership.com/v3/trackings").to_return(status: 200, body: body)
  end
end