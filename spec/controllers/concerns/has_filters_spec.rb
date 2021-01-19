require "rails_helper"

describe HasFilters do
  controller(ActionController::Base) do
    include HasFilters
    has_filters ["all", "pending", "reviewed"], only: :index

    def index
      render plain: "#{current_filter} (#{valid_filters.join(" ")})"
    end
  end

  it "has the valid filters set up" do
    get :index
    expect(response.body).to eq("all (all pending reviewed)")
  end

  describe "the current filter" do
    it "defaults to the first one on the list" do
      get :index
      expect(response.body).to eq("all (all pending reviewed)")
    end

    it "can be changed by the filter param" do
      get :index, params: { filter: "pending" }
      expect(response.body).to eq("pending (all pending reviewed)")
    end

    it "defaults to the first one on the list if given a bogus filter" do
      get :index, params: { filter: "foobar" }
      expect(response.body).to eq("all (all pending reviewed)")
    end
  end
end
