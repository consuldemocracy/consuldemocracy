class Admin::Debates::VotesComponent < ApplicationComponent
  attr_reader :debate
  delegate :votes_percentage, to: :helpers

  def initialize(debate)
    @debate = debate
  end
end
