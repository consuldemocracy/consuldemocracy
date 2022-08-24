module Mutations
  class DeleteImage < BaseMutation
    argument :id, ID, required: true

    type Types::ImageType

    def resolve(id:)
      begin
        user = context[:current_resource]
        image = Image.find id

        raise_error_unless_permitted! :destroy, image

        image.delete
        image
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
