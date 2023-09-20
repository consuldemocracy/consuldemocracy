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
      if votable.class.name == "Debate"
        debate_votes_path(votable, value: value)
      else
        legislation_process_proposal_votes_path(votable.process, votable, value: value)
      end
    end
end
