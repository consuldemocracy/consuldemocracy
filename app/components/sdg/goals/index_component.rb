class SDG::Goals::IndexComponent < ApplicationComponent
  attr_reader :goals

  def initialize(goals)
    @goals = goals
  end
end
