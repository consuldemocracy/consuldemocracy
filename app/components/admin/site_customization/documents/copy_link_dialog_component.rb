class Admin::SiteCustomization::Documents::CopyLinkDialogComponent < ApplicationComponent
  with_collection_parameter :document
  attr_reader :document

  def initialize(document:)
    @document = document
  end

  def dialog_id
    "#{dom_id(document)}-dialog"
  end

  def dialog_label_id
    "#{dom_id(document)}-dialog-heading"
  end
end
