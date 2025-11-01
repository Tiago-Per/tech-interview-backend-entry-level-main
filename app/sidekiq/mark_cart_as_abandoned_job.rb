class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_abandoned_carts
    remove_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.where(abandoned: false)
        .where('last_interaction_at < ?', 3.hours.ago)
        .update_all(abandoned: true, updated_at: Time.current)
  end

  def remove_abandoned_carts
    Cart.where(abandoned: true)
        .where('last_interaction_at < ?', 7.days.ago)
        .destroy_all
  end
end
