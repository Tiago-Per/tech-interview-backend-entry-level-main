class MarkCartAsAbandonedJob
  include Sidekiq::Job
  
  def perform
    mark_abandoned_carts
    remove_abandoned_carts
  end

  private

  def mark_abandoned_carts
    threshold = 3.hours.ago

    carts_to_mark = Cart
      .where(abandoned: false)
      .where('updated_at < ?', threshold)

    carts_to_mark.find_each do |cart|
      cart.update!(abandoned: true)
      Rails.logger.info("Cart ##{cart.id} marked as abandoned")
    end
  end

  def remove_abandoned_carts
    threshold = 7.days.ago

    carts_to_delete = Cart
      .where(abandoned: true)
      .where('updated_at < ?', threshold)

    carts_to_delete.find_each do |cart|
      cart.destroy!
      Rails.logger.info("Cart ##{cart.id} removed after 7 days abandoned")
    end
  end
end
