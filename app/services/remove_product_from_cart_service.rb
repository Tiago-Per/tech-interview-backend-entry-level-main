class RemoveProductFromCartService
  def initialize(cart, product_id)
    @cart = cart
    @product_id = product_id
  end

  def call
    cart_item = @cart.cart_items.find_by(product_id: @product_id)
    raise ActiveRecord::RecordNotFound, "Product not found in cart" unless cart_item

    cart_item.destroy
    
    @cart.recalculate_total!
    @cart
  end
end
