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

  describe "#votation_type_essay_auto_option" do
    it "create a auto_option after create a votation_type with vote_type essay" do
      votation_type = build(:votation_type_essay)

      expect(votation_type.questionable.question_options.count).to eq 0

      votation_type.save!

      expect(votation_type.questionable.question_options.count).to eq 1
    end

    it "no create a auto_option after create a votation_type with vote_type unique" do
      votation_type = build(:votation_type_unique)

      expect(votation_type.questionable.question_options.count).to eq 0

      votation_type.save!

      expect(votation_type.questionable.question_options.count).to eq 0
    end

    it "no create a auto_option after create a votation_type with vote_type multiple" do
      votation_type = build(:votation_type_multiple)

      expect(votation_type.questionable.question_options.count).to eq 0

      votation_type.save!

      expect(votation_type.questionable.question_options.count).to eq 0
    end
  end
end
