require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let!(:active_cart) { create(:cart, abandoned: false, last_interaction_at: 4.hours.ago) }
    let!(:recent_cart) { create(:cart, abandoned: false, last_interaction_at: 1.hour.ago) }
    let!(:old_abandoned_cart) { create(:cart, abandoned: true, last_interaction_at: 8.days.ago) }

    it 'marks inactive carts as abandoned' do
      expect { described_class.new.perform }
        .to change { active_cart.reload.abandoned? }.from(false).to(true)
      
      # Recent cart should not be marked as abandoned
      expect(recent_cart.reload.abandoned?).to eq(false)
    end

    it 'removes carts abandoned for more than 7 days' do
      expect { described_class.new.perform }
        .to change { Cart.exists?(old_abandoned_cart.id) }.from(true).to(false)
    end
  end
end