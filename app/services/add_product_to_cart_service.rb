class AddProductToCartService
  def initialize(cart, product_id, quantity)
    @cart = cart
    @product = Product.find(product_id)
    @quantity = quantity.to_i
  end

  def call
    cart_item = @cart.cart_items.find_or_initialize_by(product: @product)
    cart_item.quantity ||= 0
    cart_item.quantity += @quantity
    cart_item.save!

    @cart.recalculate_total!
    @cart
  end
end