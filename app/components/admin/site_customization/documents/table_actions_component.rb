class Admin::SiteCustomization::Documents::TableActionsComponent < ApplicationComponent
  attr_reader :document

  def initialize(document)
    @document = document
  end

  private

    def permanent_document_path
      rails_storage_proxy_path(document.attachment)
    end
end
