require_dependency Rails.root.join('app', 'models', 'comment').to_s

class Comment < ActiveRecord::Base

  def register_vote(user, vote_value)
    previous_vote_value = ::CastToBoolean.call(user.voted_as_when_voted_for(self))
    current_vote_value = ::CastToBoolean.call(vote_value)
    if previous_vote_value == current_vote_value
      unvote voter: user
    else
      vote_by(voter: user, vote: vote_value)
    end
  end

end
