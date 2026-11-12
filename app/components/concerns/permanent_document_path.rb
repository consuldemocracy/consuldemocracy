module PermanentDocumentPath
  extend ActiveSupport::Concern

  private

    def permanent_document_path(document)
      rails_storage_proxy_path(document.attachment, disposition: "attachment")
    end
end
