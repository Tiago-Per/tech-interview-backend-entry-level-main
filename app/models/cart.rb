class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

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

  def recalculate_total!
    total = cart_items.includes(:product).sum { |ci| ci.product.price * ci.quantity }
    update!(total_price: total)
  end

  def mark_as_abandoned
    if last_interaction_at < 3.hours.ago
      update!(abandoned: true)
    end
  end

  def remove_if_abandoned
    if abandoned? && last_interaction_at < 7.days.ago
      destroy!
    end
  end
end
