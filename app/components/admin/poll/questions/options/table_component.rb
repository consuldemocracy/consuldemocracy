class Admin::Poll::Questions::Options::TableComponent < ApplicationComponent
  attr_reader :question
  delegate :wysiwyg, to: :helpers

  def initialize(question)
    @question = question
  end
end
