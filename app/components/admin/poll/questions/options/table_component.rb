class Admin::Poll::Questions::Options::TableComponent < ApplicationComponent
  attr_reader :question
  delegate :wysiwyg, to: :helpers

  def initialize(question)
    @question = question
  end

  private

    def attribute_name(attribute)
      Poll::Question::Option.human_attribute_name(attribute)
    end
end
