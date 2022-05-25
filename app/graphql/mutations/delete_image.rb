module Mutations
  class DeleteImage < BaseMutation
    argument :id, ID, required: true

    type Types::ImageType

    def resolve(id:)
      begin
        user = context[:current_resource]
        image = Image.find id

        unless image.imageable&.author&.id == user.id
          raise GraphQL::ExecutionError,
            "User '#{user.username}' is not authorized to delete Document with id '#{image.id}'"
        end

        image.delete
        image
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
