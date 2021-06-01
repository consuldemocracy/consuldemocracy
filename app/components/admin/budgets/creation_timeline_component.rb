class Admin::Budgets::CreationTimelineComponent < ApplicationComponent
  attr_reader :current_step

  def initialize(step:)
    @current_step = step
  end

  private

    def steps
      %w[budget groups]
    end
end
