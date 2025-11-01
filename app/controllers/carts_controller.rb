class CartsController < ApplicationController
  # POST /cart
  def create
    cart = current_cart
    cart = AddProductToCartService.new(cart, cart_params[:product_id], cart_params[:quantity]).call

    render json: cart.as_json_payload, status: :created
  end

  private

  def current_cart
    if session[:cart_id]
      Cart.find(session[:cart_id])
    else
      cart = Cart.create!
      session[:cart_id] = cart.id
      cart
    end
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end
end