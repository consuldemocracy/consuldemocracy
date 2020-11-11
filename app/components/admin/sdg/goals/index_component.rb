class Admin::SDG::Goals::IndexComponent < ApplicationComponent
  attr_reader :goals

  def initialize(goals)
    @goals = goals
  end

  private

    def title
      t("admin.sdg.goals.index.title")
    end

    def attribute_name(attribute)
      SDG::Goal.human_attribute_name(attribute)
    end
end
