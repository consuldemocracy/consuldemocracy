class Polls::Questions::QuestionComponent < ApplicationComponent
  attr_reader :question

  def initialize(question:)
    @question = question
  end
end
