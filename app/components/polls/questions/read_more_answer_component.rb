class Polls::Questions::ReadMoreAnswerComponent < ApplicationComponent
  with_collection_parameter :answer
  attr_reader :answer
  delegate :wysiwyg, to: :helpers

  def initialize(answer:)
    @answer = answer
  end
end
