class Admin::Poll::Questions::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :question, :url

  def initialize(question, url:)
    @question = question
    @url = url
  end
end
