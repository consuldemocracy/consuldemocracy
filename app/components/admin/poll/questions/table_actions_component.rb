class Admin::Poll::Questions::TableActionsComponent < ApplicationComponent
  attr_reader :question

  def initialize(question)
    @question = question
  end
end
