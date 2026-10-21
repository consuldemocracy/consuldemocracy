require "rails_helper"

describe Shared::SuggestComponent do
  describe "#resource_name" do
    it "uses a default resource name as i18n namespace" do
      create(:debate, title: "More schools?")

      render_inline Shared::SuggestComponent.new(Debate.all, search_terms: "school")

      expect(page).to have_content "There is a debate with the term 'school'"
    end

    it "can be overwritten" do
      create(:legislation_proposal, title: "More schools!")

      render_inline Shared::SuggestComponent.new(
        Legislation::Proposal.all, search_terms: "school", resource_name: "proposal"
      )

      expect(page).to have_content "There is a proposal with the term 'school'"
    end
  end
end
