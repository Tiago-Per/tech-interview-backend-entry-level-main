require 'rails_helper'

RSpec.describe RemoveProductFromCartService, type: :service do
  describe '#call' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    it 'removes the item from the cart' do
      expect {
        RemoveProductFromCartService.new(cart, product.id).call
      }.to change { cart.cart_items.count }.from(1).to(0)

      expect(cart.reload.total_price).to eq(0)
    end

    it 'raises error if the product is not in the cart' do
      cart_item.destroy
      expect {
        RemoveProductFromCartService.new(cart, product.id).call
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
