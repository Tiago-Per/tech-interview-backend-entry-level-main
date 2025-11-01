require 'rails_helper'

RSpec.describe AddProductToCartService, type: :service do
  describe '#call' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }

    context 'when the product is not in the cart' do
      it 'adds a new item to the cart' do
        expect {
          AddProductToCartService.new(cart, product.id, 2).call
        }.to change { cart.cart_items.count }.by(1)

        expect(cart.cart_items.last.quantity).to eq(2)
        expect(cart.reload.total_price).to eq(20.0)
      end
    end

    context 'when the product is already in the cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it 'increments the quantity of the existing item' do
        expect {
          AddProductToCartService.new(cart, product.id, 2).call
        }.to change { cart_item.reload.quantity }.from(1).to(3)

        expect(cart.reload.total_price).to eq(30.0)
      end
    end
  end
end
