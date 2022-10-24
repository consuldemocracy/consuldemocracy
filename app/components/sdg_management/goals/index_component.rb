class SDGManagement::Goals::IndexComponent < ApplicationComponent
  include Header

  attr_reader :goals

  def initialize(goals)
    @goals = goals
  end

  private

    def title
      SDG::Goal.model_name.human(count: 2).titleize
    end

    def attribute_name(attribute)
      SDG::Goal.human_attribute_name(attribute)
    end
end
