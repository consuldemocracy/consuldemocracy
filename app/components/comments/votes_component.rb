class Comments::VotesComponent < ApplicationComponent
  attr_reader :comment
  delegate :can?, :current_user, to: :helpers

  def initialize(comment)
    @comment = comment
  end

  def pressed?(value)
    case current_user&.voted_as_when_voted_for(comment)
    when true
      value == "yes"
    when false
      value == "no"
    else
      false
    end
  end

  def vote_in_favor_against_path(value)
    if user_already_voted_with(value)
      vote = comment.votes_for.find_by!(voter: current_user)

      comment_vote_path(comment, vote, value: value)
    else
      comment_votes_path(comment, value: value)
    end
  end

  def user_already_voted_with(value)
    current_user&.voted_as_when_voted_for(comment) == parse_vote(value)
  end

  def parse_vote(value)
    value == "yes" ? true : false
  end

  def remote_submit(value)
    if user_already_voted_with(value)
      can?(:destroy, comment.votes_for.new(voter: current_user))
    else
      can?(:create, comment.votes_for.new(voter: current_user))
    end
  end
end
