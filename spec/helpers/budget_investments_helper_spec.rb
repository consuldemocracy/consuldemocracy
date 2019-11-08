require "rails_helper"

RSpec.describe BudgetInvestmentsHelper, type: :helper do
  describe "#set_direction" do
    it "returns ASC if current_direction is DESC" do
      expect(set_direction("desc")).to eq "asc"
    end

    it "returns DESC if current_direction is ASC" do
      expect(set_direction("asc")).to eq "desc"
    end

    it "returns DESC if current_direction is nil" do
      expect(set_direction(nil)).to eq "desc"
    end
  end

  describe "#set_sorting_icon" do
    let(:sort_by) { "title" }
    let(:params)  { { sort_by: sort_by } }

    it "returns arrow down if current direction is ASC" do
      expect(set_sorting_icon("asc", sort_by)).to eq "asc"
    end

    it "returns arrow top if current direction is DESC" do
      expect(set_sorting_icon("desc", sort_by)).to eq "desc"
    end

    it "returns arrow down if sort_by present, but no direction" do
      expect(set_sorting_icon(nil, sort_by)).to eq "asc"
    end

    it "returns no icon if sort_by and direction is missing" do
      params[:sort_by] = nil
      expect(set_sorting_icon(nil, sort_by)).to eq ""
    end

    it "returns no icon if sort_by is incorrect" do
      params[:sort_by] = "random"
      expect(set_sorting_icon("asc", sort_by)).to eq ""
    end
  end
end
