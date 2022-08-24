module Mutations
  class DeleteDocument < BaseMutation
    argument :id, ID, required: true

    type Types::DocumentType

    def resolve(id:)
      begin
        user = context[:current_resource]
        document = Document.find id

        raise_error_unless_permitted! :destroy, document

        document.delete
        document
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
