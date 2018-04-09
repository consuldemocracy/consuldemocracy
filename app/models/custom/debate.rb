require_dependency Rails.root.join('app', 'models', 'debate').to_s

class Debate < ActiveRecord::Base

  def register_vote(user, vote_value)
    if votable_by?(user)
      previous_vote_value = ::CastToBoolean.call(user.voted_as_when_voted_for(self))
      current_vote_value = ::CastToBoolean.call(vote_value)
      if previous_vote_value == current_vote_value
        Debate.decrement_counter(:cached_anonymous_votes_total, id) if user.unverified? && user.voted_for?(self)
        unvote voter: user
      else
        Debate.increment_counter(:cached_anonymous_votes_total, id) if user.unverified? && !user.voted_for?(self)
        vote_by(voter: user, vote: vote_value)
      end
    end
  end

  # inspired by editable? method
  def destroyable?
    self.comments.count == 0 && self.votes_for.count == 0
  end

  def destroyable_by?(user)
    destroyable? && author == user
  end


end
