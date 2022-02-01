class Documents::NestedComponent < ApplicationComponent
  attr_reader :f

  def initialize(f)
    @f = f
  end

  private

    def documentable
      f.object
    end

    def max_documents_allowed
      documentable.class.max_documents_allowed
    end

    def note
      t "documents.form.note", max_documents_allowed: max_documents_allowed,
        accepted_content_types: Document.humanized_accepted_content_types,
        max_file_size: documentable.class.max_file_size
    end

    def max_documents_allowed?
      documentable.documents.count >= max_documents_allowed
    end
end
