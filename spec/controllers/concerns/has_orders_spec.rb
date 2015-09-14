require 'rails_helper'

describe 'HasOrders' do

  class FakeController < ActionController::Base; end

  controller(FakeController) do
    include HasOrders
    has_orders ['created_at', 'votes_count', 'flags_count'], only: :index

    def index
      render text: "#{@current_order} (#{@valid_orders.join(' ')})"
    end
  end

  it "has the valid orders set up" do
    get :index
    expect(response.body).to eq('created_at (created_at votes_count flags_count)')
  end

  describe "the current order" do
    it "defaults to the first one on the list" do
      get :index
      expect(response.body).to eq('created_at (created_at votes_count flags_count)')
    end

    it "can be changed by the order param" do
      get :index, order: 'votes_count'
      expect(response.body).to eq('votes_count (created_at votes_count flags_count)')
    end

    it "defaults to the first one on the list if given a bogus order" do
      get :index, order: 'foobar'
      expect(response.body).to eq('created_at (created_at votes_count flags_count)')
    end
  end
end
