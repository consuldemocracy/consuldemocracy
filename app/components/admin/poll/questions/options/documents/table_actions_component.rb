class Admin::Poll::Questions::Options::Documents::TableActionsComponent < ApplicationComponent
  attr_reader :document

  def initialize(document)
    @document = document
  end
end
