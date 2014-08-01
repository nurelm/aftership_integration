class BadResponseError < AftershipError
  def initialize(response)
    super("#{response['meta']['error_type']}: #{response['meta']['error_message']} (code #{response['meta']['code']})")
  end
end
