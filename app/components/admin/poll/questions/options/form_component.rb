class Admin::Poll::Questions::Options::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :option, :url

  def initialize(option, url:)
    @option = option
    @url = url
  end

  private

    def allow_custom_text_help_id(form)
      form.field_id(:allow_custom_text, :help)
    end
end
