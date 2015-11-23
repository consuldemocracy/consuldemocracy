require 'rails_helper'

describe OrdersHelper do

  describe '#valid_orders' do
    it 'displays relevance when searching' do
      params[:search] = 'ipsum'
      assign(:valid_orders, %w(created_at random relevance))
      expect(helper.valid_orders).to eq %w(created_at random relevance)
    end

    it 'does not display relevance when not searching' do
      assign(:valid_orders, %w(created_at random relevance))
      expect(helper.valid_orders).to eq %w(created_at random)
    end
  end

end