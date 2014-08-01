class BadTrackingNumberError < AftershipError
  def initialize
    @code = 500
    super("Was provided wrong or not supported Tracking Number.")
  end
end
