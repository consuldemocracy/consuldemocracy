require "rails_helper"

describe HasOrders do

  class FakeController < ActionController::Base; end

  controller(FakeController) do
    include HasOrders
    has_orders ["created_at", "votes_count", "flags_count", "relevance"], only: :index
    has_orders ->(c) { ["votes_count", "flags_count"] }, only: :new

    def index
      render text: "#{@current_order} (#{@valid_orders.join(' ')})"
    end

    def new
      render text: "#{@current_order} (#{@valid_orders.join(' ')})"
    end
  end

  it "displays all the orders except relevance when not searching" do
    get :index
    expect(response.body).to eq("created_at (created_at votes_count flags_count)")
  end

  it "allows specifying the orders via a lambda" do
    get :new
    expect(response.body).to eq("votes_count (votes_count flags_count)")
  end

  it "displays relevance when searching" do
    get :index, search: "ipsum"
    expect(response.body).to eq("created_at (created_at votes_count flags_count relevance)")
  end

  it "does not overwrite the has_orders options when doing several requests" do
    get :index
    # Since has_orders did valid_options.delete, the first call to :index might remove 'relevance' from
    # the list by mistake.
    get :index, search: "ipsum"
    expect(response.body).to eq("created_at (created_at votes_count flags_count relevance)")
  end

  describe "the current order" do
    it "defaults to the first one on the list" do
      get :index
      expect(response.body).to eq("created_at (created_at votes_count flags_count)")
    end

    it "can be changed by the order param" do
      get :index, order: "votes_count"
      expect(response.body).to eq("votes_count (created_at votes_count flags_count)")
    end

    it "defaults to the first one on the list if given a bogus order" do
      get :index, order: "foobar"
      expect(response.body).to eq("created_at (created_at votes_count flags_count)")
    end
  end
end
