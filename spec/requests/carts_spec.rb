require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]).and_call_original
    allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]).with(:cart_id).and_return(cart.id)
    allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]=).and_call_original
  end

  describe "POST /cart/add_item" do
    context 'when the product already is in the cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it 'updates the quantity of the existing item in the cart' do
        2.times do
          post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        end

        expect(cart_item.reload.quantity).to eq(3)
      end
    end

    context 'when the product does not exist in the cart' do
      let(:new_product) { create(:product, name: "New Product", price: 5.0) }

      it 'adds a new item to the cart' do
        expect {
          post '/cart/add_item', params: { product_id: new_product.id, quantity: 2 }, as: :json
        }.to change { cart.cart_items.count }.by(1)

        expect(cart.cart_items.last.quantity).to eq(2)
      end
    end
  end

  describe "GET /cart" do
    it "returns the cart with correct total price and items" do
      create(:cart_item, cart: cart, product: product, quantity: 2)
      cart.recalculate_total!

      get '/cart', as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['products'].size).to eq(1)
      expect(json['total_price']).to eq(20.0)
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product) }

    it "removes the item from the cart" do
      expect {
        delete "/cart/#{product.id}", as: :json
      }.to change { cart.cart_items.count }.by(-1)
    end

    it "returns 404 if product not in cart" do
      delete "/cart/9999", as: :json
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to include("Product not found in cart")
    end
  end
end
