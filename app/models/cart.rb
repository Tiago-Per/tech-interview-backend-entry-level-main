class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy

  def as_json_payload
    {
      id: id,
      products: cart_items.includes(:product).map do |ci|
        {
          id: ci.product.id,
          name: ci.product.name,
          quantity: ci.quantity,
          unit_price: ci.product.price.to_f,
          total_price: (ci.product.price * ci.quantity).to_f
        }
      end,
      total_price: total_price.to_f
    }
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
