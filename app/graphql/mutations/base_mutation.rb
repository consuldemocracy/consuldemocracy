module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    def raise_error_unless_permitted!(action, subject, user = context[:current_resource])
      unless user.can? action, subject
        raise GraphQL::ExecutionError,
          "User '#{user.username}' is not authorized to #{action} #{subject.class} with id '#{subject.id}'"
      end
    end
  end
end
