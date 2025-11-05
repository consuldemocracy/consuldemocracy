# app/components/shared/in_favor_neutral_against_component.rb
class Shared::InFavorNeutralAgainstComponent < ApplicationComponent
  attr_reader :votable
  
  # Make sure to include the new helper
  use_helpers :vote_percentage_for_weight

  def initialize(votable)
    @votable = votable
  end

  private

  # These helpers are for accessibility (aria-label)
  def agree_aria_label
    t("votes.agree_label", title: votable.title)
  end

  def disagree_aria_label
    t("votes.disagree_label", title: votable.title)
  end

  def neutral_aria_label
    t("votes.neutral_label", title: votable.title)
  end
end