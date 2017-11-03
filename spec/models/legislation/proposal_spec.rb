require 'rails_helper'

describe Legislation::Proposal do
  let(:legislation_proposal) { build(:legislation_proposal) }

  it "should be valid" do
    expect(legislation_proposal).to be_valid
  end

  describe "title length" do
    it "a title length smaller than TITLE_MIN_LENGTH is invalid" do
      proposal = build(:legislation_proposal, title: Faker::Lorem.characters(Legislation::Proposal::TITLE_MIN_LENGTH - 1))
      expect(proposal).not_to be_valid
    end

    it "a title length between TITLE_MIN_LENGTH and TITLE_MAX_LENGTH is valid" do
      title_length = rand(Legislation::Proposal::TITLE_MIN_LENGTH..Legislation::Proposal::TITLE_MAX_LENGTH)
      proposal = build(:legislation_proposal, title: Faker::Lorem.characters(title_length))
      expect(proposal).to be_valid
    end

    it "a title length greater than TITLE_MXN_LENGTH is invalid" do
      proposal = build(:legislation_proposal, title: Faker::Lorem.characters(Legislation::Proposal::TITLE_MAX_LENGTH + 1))
      expect(proposal).not_to be_valid
    end
  end
end
