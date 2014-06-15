class BadResponseError < AftershipError
  def initialize(response)
    @code = response['meta']['code']
    super("#{response['meta']['error_type']}: #{response['meta']['error_message']}")
  end
end