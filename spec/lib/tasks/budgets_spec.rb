require "rails_helper"

describe "budget tasks" do
  describe "rake budgets:email:selected" do
    before { Rake::Task["budgets:email:selected"].reenable }

    it "sends emails to users from the current budget and not the last budget created" do
      create(:budget_investment, :selected, author: create(:user, email: "selectme@consul.dev"))
      create(:budget, :drafting)

      Rake.application.invoke_task("budgets:email:selected")

      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(ActionMailer::Base.deliveries.last.to).to eq ["selectme@consul.dev"]
    end
  end

  describe "rake budgets:email:unselected" do
    before { Rake::Task["budgets:email:unselected"].reenable }

    it "sends emails to users from the current budget and not the last budget created" do
      create(:budget_investment, author: create(:user, email: "ignorme@consul.dev"))
      create(:budget, :drafting)

      Rake.application.invoke_task("budgets:email:unselected")

      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(ActionMailer::Base.deliveries.last.to).to eq ["ignorme@consul.dev"]
    end
  end
end
