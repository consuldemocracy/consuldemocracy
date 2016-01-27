class OpenAnswer < ActiveRecord::Base
  belongs_to :survey_answer
  acts_as_votable

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
end
