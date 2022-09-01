class Polls::Questions::ReadMoreAnswerComponent < ApplicationComponent
  with_collection_parameter :question
  attr_reader :question
  delegate :wysiwyg, to: :helpers

  def initialize(question:)
    @question = question
  end
end
