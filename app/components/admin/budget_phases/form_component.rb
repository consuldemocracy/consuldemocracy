class Admin::BudgetPhases::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :phase

  def initialize(phase)
    @phase = phase
  end
end
