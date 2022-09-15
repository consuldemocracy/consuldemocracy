class Admin::Poll::Questions::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :poll, :question, :url

  def initialize(poll, question, url:)
    @poll = poll
    @question = question
    @url = url
  end
end
