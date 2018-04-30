require 'rails_helper'

describe Valuator do

  describe "#description_or_email" do
    it "returns description if present" do
      valuator = create(:valuator, description: "Urbanism manager")

      expect(valuator.description_or_email).to eq("Urbanism manager")
    end

    it "returns email if not description present" do
      valuator = create(:valuator)

      expect(valuator.description_or_email).to eq(valuator.email)
    end
  end
end

# == Schema Information
#
# Table name: valuators
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  description              :string
#  spending_proposals_count :integer          default(0)
#  budget_investments_count :integer          default(0)
#
