class Admin::Poll::Questions::Options::Documents::TableActionsComponent < ApplicationComponent
  include PermanentDocumentPath

  attr_reader :document

  def initialize(document)
    @document = document
  end
end
