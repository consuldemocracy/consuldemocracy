class Admin::SiteCustomization::Documents::IndexComponent < ApplicationComponent
  attr_reader :documents

  def initialize(documents)
    @documents = documents
  end

  private

    def permanent_document_path(document)
      rails_storage_proxy_path(document.attachment)
    end
end
