class Polls::Questions::ReadMoreComponent < ApplicationComponent
  with_collection_parameter :question
  attr_reader :question
  use_helpers :wysiwyg

  def initialize(question:)
    @question = question
  end

  def render?
    question.answers_with_read_more?
  end
end
