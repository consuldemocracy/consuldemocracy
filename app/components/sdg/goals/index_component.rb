class SDG::Goals::IndexComponent < ApplicationComponent
  attr_reader :goals
  delegate :link_list, to: :helpers

  def initialize(goals)
    @goals = goals
  end
end
