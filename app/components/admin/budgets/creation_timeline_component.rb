class Admin::Budgets::CreationTimelineComponent < ApplicationComponent
  attr_reader :step

  def initialize(step:)
    @step = step
  end

  private

    def step_groups?
      step == "groups"
    end
end
