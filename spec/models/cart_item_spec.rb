require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it 'belongs to a cart' do
      cart = create(:cart)
      cart_item = create(:cart_item, cart: cart)
      expect(cart_item.cart).to eq(cart)
    end

    it 'belongs to a product' do
      product = create(:product)
      cart_item = create(:cart_item, product: product)
      expect(cart_item.product).to eq(product)
    end
  end

  describe 'validations' do
    it 'validates quantity is greater than or equal to 1' do
      cart_item = build(:cart_item, quantity: 0)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than or equal to 1")
    end
  end
end
