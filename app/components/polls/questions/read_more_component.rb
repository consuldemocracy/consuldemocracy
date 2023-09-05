class Polls::Questions::ReadMoreComponent < ApplicationComponent
  with_collection_parameter :question
  attr_reader :question
  delegate :wysiwyg, to: :helpers

  def initialize(question:)
    @question = question
  end

  def render?
    question.answers_with_read_more?
  end
end
