require "rails_helper"

RSpec.describe Poll::Question do
  let(:poll_question) { build(:poll_question) }

  describe "Concerns" do
    it_behaves_like "acts as paranoid", :poll_question
    it_behaves_like "globalizable", :poll_question
  end

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
      it "correctly creates a translation" do
        I18n.with_locale(:"pt-BR") do
          poll_question.copy_attributes_from_proposal(proposal)
        end

        translation = poll_question.translations.first

        expect(poll_question.title).to eq(proposal.title)
        expect(translation.title).to eq(proposal.title)
        expect(translation.locale).to eq(:"pt-BR")
      end
    end
  end

  describe "#options_total_votes" do
    let!(:question) { create(:poll_question) }
    let!(:option_yes) { create(:poll_question_option, question: question, title_en: "Yes", title_es: "Sí") }
    let!(:option_no) { create(:poll_question_option, question: question, title_en: "No", title_es: "No") }

    before do
      create(:poll_answer, question: question, option: option_yes, answer: "Sí")
      create(:poll_answer, question: question, option: option_yes, answer: "Yes")
      create(:poll_answer, question: question, option: option_no, answer: "No")
    end

    it "includes answers in every language" do
      expect(question.options_total_votes).to eq 3
    end

    it "includes partial results counted by option_id" do
      booth_assignment = create(:poll_booth_assignment, poll: question.poll)
      create(:poll_partial_result,
             booth_assignment: booth_assignment,
             question: question,
             option: option_yes,
             amount: 4)

      expect(question.options_total_votes).to eq 7
    end

    it "does not include votes from other questions even with same answer text" do
      other_question = create(:poll_question, poll: question.poll)
      other_option_yes = create(:poll_question_option,
                                question: other_question,
                                title_en: "Yes",
                                title_es: "Sí")

      create(:poll_partial_result, question: other_question, option: other_option_yes, amount: 4)
      create(:poll_answer, question: other_question, option: other_option_yes, answer: "Yes")

      expect(question.options_total_votes).to eq 3
    end
  end
end
