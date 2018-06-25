# coding: utf-8
require 'rails_helper'

describe Proposal do
  let(:proposal) { build(:proposal) }

  describe "#responsible_name" do
    # Custom CDJ Aude ------------------------------
    it "is author name if blank and no document_number" do
      author = create(:user, username: "Jim Gallardo")
      proposal.author = author
      proposal.responsible_name = nil

      expect(proposal).to be_valid
      expect(proposal.responsible_name).to eq("Jim Gallardo")
    end

    it "is input name if given" do
      author = create(:user, username: "Jim Gallardo")
      proposal.author = author
      proposal.responsible_name = "Totoro"
      p proposal.errors unless proposal.valid?
      expect(proposal).to be_valid
      expect(proposal.responsible_name).to eq("Totoro")
    end

    # End Custom CDJ Aude -------------------------
  end

end
