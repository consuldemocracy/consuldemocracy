class Admin::Poll::Questions::Options::TableComponent < ApplicationComponent
  attr_reader :question
  use_helpers :wysiwyg

  def initialize(question)
    @question = question
  end
end
