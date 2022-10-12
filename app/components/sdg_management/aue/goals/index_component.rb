class SDGManagement::AUE::Goals::IndexComponent < ApplicationComponent
  include Header

  attr_reader :goals

  def initialize(goals)
    @goals = goals
  end

  private

    def title
      AUE::Goal.model_name.human(count: 2).titleize
    end

    def attribute_name(attribute)
      AUE::Goal.human_attribute_name(attribute)
    end
end
