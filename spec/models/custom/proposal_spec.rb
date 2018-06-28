# coding: utf-8
require 'rails_helper'

describe Proposal do
  let(:user) { create(:user, document_number: nil) }
  let(:proposal) { build(:proposal, author: user, responsible_name: nil) }

  before do
    Setting["feature.user.skip_verification"] = 'true'
  end

  after do
    Setting["feature.user.skip_verification"] = 'false'
  end

  it "is valid with user without verification" do
    expect(proposal).to be_valid
  end

  context "when Setting['org_name'] is 'MASDEMOCRACIAEUROPA'" do

    before { Setting['org_name'] = 'MASDEMOCRACIAEUROPA' }

    it "is valid without question" do
      proposal.question = nil

      expect(proposal).to be_valid
    end

    it "is valid without summary" do
      proposal.summary = nil

      expect(proposal).to be_valid
    end

    it "is not valid without objective" do
      proposal.objective = nil

      expect(proposal).not_to be_valid
    end

    it "is not valid with objective longer than maximum length" do
      proposal.objective = 'a' * (300 + 1)

      expect(proposal).not_to be_valid
    end

    it "is not valid without feasible_explanation" do
      proposal.feasible_explanation = nil

      expect(proposal).not_to be_valid
    end

    it "is not valid without feasible_explanation longer than maximum length" do
      proposal.feasible_explanation = 'a' * (300 + 1)

      expect(proposal).not_to be_valid
    end

    it "is not valid without impact_description" do
      proposal.impact_description = nil

      expect(proposal).not_to be_valid
    end

    it "is not valid without impact_description longer than maximum length" do
      proposal.impact_description = 'a' * (300 + 1)

      expect(proposal).not_to be_valid
    end
  end

end
