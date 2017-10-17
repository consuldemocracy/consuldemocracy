require 'rails_helper'

RSpec.describe Poll::Question, type: :model do
  let(:poll_question) { build(:poll_question) }

  describe "#poll_question_id" do
    it "should be invalid if a poll is not selected" do
      poll_question.poll_id = nil
      expect(poll_question).to_not be_valid
    end

    it "should be valid if a poll is selected" do
      poll_question.poll_id = 1
      expect(poll_question).to be_valid
    end
  end

  describe "#copy_attributes_from_proposal" do
    it "copies the attributes from the proposal" do
      create_list(:geozone, 3)
      p = create(:proposal)
      poll_question.copy_attributes_from_proposal(p)
      expect(poll_question.author).to eq(p.author)
      expect(poll_question.author_visible_name).to eq(p.author.name)
      expect(poll_question.proposal_id).to eq(p.id)
      expect(poll_question.title).to eq(p.title)
    end
  end

end
