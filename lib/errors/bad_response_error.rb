class BadResponseError < AftershipError
  def initialize(response)
    super("#{response['meta']['error']}: #{response['meta']['message']} (code #{response['meta']['code']})")
  end
end
