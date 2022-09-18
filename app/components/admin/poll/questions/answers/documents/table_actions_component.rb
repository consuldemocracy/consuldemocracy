class Admin::Poll::Questions::Answers::Documents::TableActionsComponent < ApplicationComponent
  attr_reader :document

  def initialize(document)
    @document = document
  end
end
