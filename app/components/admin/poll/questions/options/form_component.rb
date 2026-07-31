class Admin::Poll::Questions::Options::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :option, :url

  def initialize(option, url:)
    @option = option
    @url = url
  end
end
