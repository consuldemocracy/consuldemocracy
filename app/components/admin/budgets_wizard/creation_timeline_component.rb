class Admin::BudgetsWizard::CreationTimelineComponent < ApplicationComponent
  attr_reader :current_step

  def initialize(current_step)
    @current_step = current_step
  end

  private

    def steps
      %w[budget groups headings phases]
    end
end
