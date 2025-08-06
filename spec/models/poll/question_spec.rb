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

  describe "#validate_votation_type_essay" do
    it "question unique to essay without options is valid" do
      poll_question = create(:poll_question_unique)

      poll_question.votation_type.update!(vote_type: :essay)

      expect(poll_question).to be_valid
    end

    it "question unique to essay with options is invalid" do
      poll_question = create(:poll_question_unique)
      create(:poll_question_option, question: poll_question)

      poll_question.votation_type.update!(vote_type: :essay)

      expect(poll_question).not_to be_valid
      error = poll_question.errors[:votation_type].first
      expect(error).to eq "can't change to essay type because multiple type options already exist"
    end

    it "question multiple to essay without options is valid" do
      poll_question = create(:poll_question_multiple)

      poll_question.votation_type.update!(vote_type: :essay)

      expect(poll_question).to be_valid
    end

    it "question multiple to essay with options is invalid" do
      poll_question = create(:poll_question_multiple)
      create(:poll_question_option, question: poll_question)

      poll_question.votation_type.update!(vote_type: :essay)

      expect(poll_question).not_to be_valid
      error = poll_question.errors[:votation_type].first
      expect(error).to eq "can't change to essay type because multiple type options already exist"
    end
  end

  describe "#validate_votation_type_from_essay" do
    it "question essay to unique is invalid" do
      poll_question = create(:poll_question_essay)

      poll_question.votation_type.update!(vote_type: :unique)

      expect(poll_question).not_to be_valid
      error = poll_question.errors[:votation_type].first
      expect(error).to eq "can't change from essay type because essay options already exist"
    end

    it "question essay to multiple is invalid" do
      poll_question = create(:poll_question_essay)

      poll_question.votation_type.update!(vote_type: :multiple, max_votes: 2)

      expect(poll_question).not_to be_valid
      error = poll_question.errors[:votation_type].first
      expect(error).to eq "can't change from essay type because essay options already exist"
    end
  end
end
