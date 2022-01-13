module Types
  class MutationType < Types::BaseObject
    field :answer, mutation: Mutations::Answer, authenticate: true
    field :comment_on_poll, mutation: Mutations::CommentOnPoll, authenticate: true
  end
end
