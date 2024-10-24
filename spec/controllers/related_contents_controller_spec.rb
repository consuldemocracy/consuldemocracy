require "rails_helper"

describe RelatedContentsController do
  describe "#score" do
    it "raises an error if related content does not exist" do
      controller.params[:id] = 0

      expect do
        controller.send(:score, "action")
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "#score_positive" do
    it "increases the score of both the related content and its opposite" do
      user = create(:user, :level_two)
      related_content = create(:related_content, author: create(:user))
      opposite_content = related_content.opposite_related_content

      sign_in user

      put :score_positive, params: { id: related_content, format: :js }

      score = related_content.related_content_scores
                             .find_by(user: user, related_content: related_content)
                             .value
      opposite_score = opposite_content.related_content_scores
                                       .find_by(user: user, related_content: opposite_content)
                                       .value

      expect(score).to eq(1)
      expect(opposite_score).to eq(1)
    end
  end

  describe "#score_negative" do
    it "decreases the score of both the related content and its opposite" do
      user = create(:user, :level_two)
      related_content = create(:related_content, author: create(:user))
      opposite_content = related_content.opposite_related_content

      sign_in user

      put :score_negative, params: { id: related_content, format: :js }

      score = related_content.related_content_scores
                             .find_by(user: user, related_content: related_content)
                             .value
      opposite_score = opposite_content.related_content_scores
                                       .find_by(user: user, related_content: opposite_content)
                                       .value

      expect(score).to eq(-1)
      expect(opposite_score).to eq(-1)
    end
  end
end
