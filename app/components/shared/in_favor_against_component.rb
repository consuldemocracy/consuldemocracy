class Shared::InFavorAgainstComponent < ApplicationComponent
  attr_reader :votable
  delegate :current_user, :votes_percentage, to: :helpers

  def initialize(votable)
    @votable = votable
  end

  private

    def agree_aria_label
      t("votes.agree_label", title: votable.title)
    end

    def disagree_aria_label
      t("votes.disagree_label", title: votable.title)
    end

    def pressed?(value)
      case current_user&.voted_as_when_voted_for(votable)
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
        vote = Vote.find_by!(votable: votable, voter: current_user)
        polymorphic_path(vote)
      else
        polymorphic_path(Vote.new(votable: votable), value: value)
      end
    end

    def user_already_voted_with(value)
      current_user&.voted_as_when_voted_for(votable) == parse_vote(value)
    end

    def parse_vote(value)
      value == "yes" ? true : false
    end
end
