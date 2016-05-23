require 'rails_helper'

describe Budget do
  it "validates the phase" do
    budget = create(:budget)
    Budget::VALID_PHASES.each do |phase|
      budget.phase = phase
      expect(budget).to be_valid
    end

    budget.phase = 'inexisting'
    expect(budget).to_not be_valid
  end
end

