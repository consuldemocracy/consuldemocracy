require "rails_helper"

describe Budgets::Ballot::LinesController do
  describe "#load_budget" do
    it "raises an error if budget slug is not found" do
      controller.params[:budget_id] = "wrong_budget"

      expect do
        controller.send(:load_budget)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      controller.params[:budget_id] = 0

      expect do
        controller.send(:load_budget)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
