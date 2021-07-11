class Documents::NestedComponent < ApplicationComponent
  attr_reader :f
  delegate :documentable_humanized_accepted_content_types, :max_file_size, to: :helpers

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

    def documentables_note
      t "documents.form.note", max_documents_allowed: max_documents_allowed,
        accepted_content_types: documentable_humanized_accepted_content_types(documentable.class),
        max_file_size: max_file_size(documentable.class)
    end

    def max_documents_allowed?
      documentable.documents.count >= max_documents_allowed
    end
end
