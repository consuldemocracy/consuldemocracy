class OpenAnswer < ActiveRecord::Base
  belongs_to :survey_answer
  acts_as_votable

  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }

  before_save :calculate_confidence_score

  def total_votes
    cached_votes_total
  end

  def total_likes
    cached_votes_up
  end

  def total_dislikes
    cached_votes_down
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def votable_by?(user)
    user && user.level_two_or_three_verified?
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_likes)
  end
end
