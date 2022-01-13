module Types
  class MutationType < Types::BaseObject
    field :answer, mutation: Mutations::Answer, authenticate: true
    field :add_comment_to_poll, mutation: Mutations::AddCommentToPoll, authenticate: true
    field :add_comment_to_debate, mutation: Mutations::AddCommentToDebate, authenticate: true
    field :start_debate, mutation: Mutations::StartDebate, authenticate: true
    field :cast_vote_on_comment, mutation: Mutations::CastVoteOnComment, authenticate: true
  end
end
