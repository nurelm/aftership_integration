class BadTrackingNumberError < AftershipError
  def initialize
    @code = 404
    super("Was provided wrong or not supported Tracking Number.")
  end
end