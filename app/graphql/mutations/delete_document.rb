module Mutations
  class DeleteDocument < BaseMutation
    argument :id, ID, required: true

    type Types::DocumentType

    def resolve(id:)
      begin
        user = context[:current_resource]
        document = Document.find id

        unless document.documentable&.author&.id == user.id
          raise GraphQL::ExecutionError,
            "User '#{user.username}' is not authorized to delete Document with id '#{document.id}'"
        end

        document.delete
        document
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
