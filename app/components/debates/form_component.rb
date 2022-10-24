class Debates::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :debate
  delegate :suggest_data, to: :helpers

  def initialize(debate)
    @debate = debate
  end
end
