require "rails_helper"

describe VotationType do
  let(:vote_types) { %i[votation_type_unique votation_type_multiple votation_type_essay] }
  let(:votation_type) { build(vote_types.sample) }

  it "is valid" do
    expect(votation_type).to be_valid
  end

  it "is not valid without questionable" do
    votation_type.questionable = nil

    expect(votation_type).not_to be_valid
  end

  it "is not valid when questionable_type is not allowed" do
    votation_type.questionable_type = Poll::Answer

    expect(votation_type).not_to be_valid
    expect(votation_type.errors[:questionable_type]).to include "is not included in the list"
  end

  it "is not valid when max_votes is undefined for multiple votation_type" do
    votation_type.max_votes = nil
    votation_type.vote_type = "unique"

    expect(votation_type).to be_valid

    votation_type.max_votes = nil
    votation_type.vote_type = "essay"

    expect(votation_type).to be_valid

    votation_type.vote_type = "multiple"

    expect(votation_type).not_to be_valid
    expect(votation_type.errors[:max_votes]).to include "can't be blank"
  end

  describe "#cannot_be_essay_if_question_has_options" do
    it "allows changing to essay when the question has no options" do
      poll_question = create(:poll_question_unique)
      votation_type = poll_question.votation_type

      expect(votation_type.update(vote_type: :essay)).to be true
      expect(votation_type).to be_valid
      expect(votation_type.errors[:vote_type]).to be_empty
    end

    it "blocks changing to essay when the question has options" do
      poll_question = create(:poll_question_unique)
      create(:poll_question_option, question: poll_question)
      votation_type = poll_question.votation_type

      expect(votation_type.update(vote_type: :essay)).to be false
      expect(votation_type).not_to be_valid
      error = votation_type.errors[:vote_type].first
      expect(error).to eq "can't change to essay type because options already exist"
    end
  end
end
