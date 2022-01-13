class Shared::InFavorAgainstComponent < ApplicationComponent
  attr_reader :votable
  delegate :current_user, :votes_percentage, to: :helpers

  def initialize(votable)
    @votable = votable
  end

  private

    def voted_classes
      @voted_classes ||= css_classes_for_vote
    end

    def css_classes_for_vote
      case current_user&.voted_as_when_voted_for(votable)
      when true
        { in_favor: "voted", against: "no-voted" }
      when false
        { in_favor: "no-voted", against: "voted" }
      else
        { in_favor: "", against: "" }
      end
    end
end
