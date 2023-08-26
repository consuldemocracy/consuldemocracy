require "rails_helper"

describe VotationType do
  let(:vote_types) { %i[votation_type_unique votation_type_multiple] }
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

    votation_type.vote_type = "multiple"

    expect(votation_type).not_to be_valid
    expect(votation_type.errors[:max_votes]).to include "can't be blank"
  end
end
