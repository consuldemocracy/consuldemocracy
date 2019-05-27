require "rails_helper"

RSpec.describe Poll::Question, type: :model do
  let(:poll_question) { build(:poll_question) }

  describe "#poll_question_id" do
    it "is invalid if a poll is not selected" do
      poll_question.poll_id = nil
      expect(poll_question).not_to be_valid
    end

    it "is valid if a poll is selected" do
      poll_question.poll_id = 1
      expect(poll_question).to be_valid
    end
  end

  describe "#copy_attributes_from_proposal" do
    before { create_list(:geozone, 3) }
    let(:proposal) { create(:proposal) }

    it "copies the attributes from the proposal" do
      poll_question.copy_attributes_from_proposal(proposal)
      expect(poll_question.author).to eq(proposal.author)
      expect(poll_question.author_visible_name).to eq(proposal.author.name)
      expect(poll_question.proposal_id).to eq(proposal.id)
      expect(poll_question.title).to eq(proposal.title)
    end

    context "locale with non-underscored name" do
      before do
        I18n.locale = :"pt-BR"
        Globalize.locale = I18n.locale
      end

      it "correctly creates a translation" do
        poll_question.copy_attributes_from_proposal(proposal)
        translation = poll_question.translations.first

        expect(poll_question.title).to eq(proposal.title)
        expect(translation.title).to eq(proposal.title)
        expect(translation.locale).to eq(:"pt-BR")
      end
    end
  end

end
