class Debates::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :debate
  delegate :suggest_data, :invisible_captcha, to: :helpers

  def initialize(debate)
    @debate = debate
  end
end
