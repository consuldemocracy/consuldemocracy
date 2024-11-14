class Admin::ProgressBars::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :progress_bar

  def initialize(progress_bar)
    @progress_bar = progress_bar
  end

  private

    def progress_options
      { min: ProgressBar::RANGE.min, max: ProgressBar::RANGE.max, step: 1 }
    end
end
