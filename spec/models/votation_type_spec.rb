require "rails_helper"

describe VotationType do
  let(:vote_types) { %i[votation_type_unique votation_type_multiple votation_type_open] }
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

    votation_type.vote_type = "open"

    expect(votation_type).to be_valid

    votation_type.vote_type = "multiple"

    expect(votation_type).not_to be_valid
    expect(votation_type.errors[:max_votes]).to include "can't be blank"
  end

  describe "#cannot_be_open_ended_if_question_has_options" do
    it "allows changing to open-ended when the question has no options" do
      votation_type = create(:votation_type_unique)

      votation_type.vote_type = :open

      expect(votation_type).to be_valid
    end

    it "blocks changing to open-ended when the question has options" do
      votation_type = create(:votation_type_unique)
      create(:poll_question_option, question: votation_type.questionable)

      votation_type.vote_type = :open

      expect(votation_type).not_to be_valid
      error = votation_type.errors[:vote_type].first
      expect(error).to eq "can't change to open-ended type " \
                          "because you've already defined possible valid answers for this question"
    end
  end

  describe "scopes" do
    describe ".accepts_options" do
      it "includes unique and multiple, excludes open_ended" do
        question_unique = create(:poll_question_unique)
        question_multiple = create(:poll_question_multiple)
        question_open_ended = create(:poll_question_open)

        accepts_options = VotationType.accepts_options

        expect(accepts_options).to match_array [question_unique.votation_type,
                                                question_multiple.votation_type]
        expect(accepts_options).not_to include question_open_ended.votation_type
      end
    end
  end
end
