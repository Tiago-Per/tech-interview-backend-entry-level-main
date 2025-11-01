class CartsController < ApplicationController
  # POST /cart
  def create
    cart = current_cart
    cart = AddProductToCartService.new(cart, cart_params[:product_id], cart_params[:quantity]).call

    render json: cart.as_json_payload, status: :created
  end

  # GET /cart
  def show
    cart = current_cart
    render json: cart.as_json_payload
  end

  private

  def current_cart
    if session[:cart_id]
      Cart.find(session[:cart_id])
    else
      cart = Cart.create!(total_price: 0)
      session[:cart_id] = cart.id
      cart
    end
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end
end