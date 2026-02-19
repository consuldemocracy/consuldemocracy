class Admin::Debates::VotesComponent < ApplicationComponent
  attr_reader :debate
  use_helpers :votes_percentage

  def initialize(debate)
    @debate = debate
  end
end
