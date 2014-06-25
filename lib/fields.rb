module Fields
  def custom_fields
    %w(id order_id email cost status stock_location shipping_method tracking shipped_at)
  end

  def shipping_address_fields
    %w(phone country state city zipcode address1 address2 firstname lastname)
  end

  def item_fields
    %w(options price quantity product_id name)
  end
end