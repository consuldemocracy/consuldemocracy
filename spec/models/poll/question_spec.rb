require 'rails_helper'

RSpec.describe Poll::Question, type: :model do

  describe "#valid_answers" do
    it "gets a comma-separated string, but returns an array" do
      q = create(:poll_question, valid_answers: "Yes, No")
      expect(q.valid_answers).to eq(["Yes", "No"])
    end
  end

  describe "#copy_attributes_from_proposal" do
    it "copies the attributes from the proposal" do
      create_list(:geozone, 3)
      p = create(:proposal)
      q = create(:poll_question)
      q.copy_attributes_from_proposal(p)
      expect(q.valid_answers).to eq(['Yes', 'No'])
      expect(q.author).to eq(p.author)
      expect(q.author_visible_name).to eq(p.author.name)
      expect(q.proposal_id).to eq(p.id)
      expect(q.title).to eq(p.title)
    end
  end

end
