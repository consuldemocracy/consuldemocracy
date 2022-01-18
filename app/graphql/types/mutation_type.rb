module Types
  class MutationType < Types::BaseObject
    field :add_comment_to_debate, mutation: Mutations::AddCommentToDebate, authenticate: true
    field :add_comment_to_poll, mutation: Mutations::AddCommentToPoll, authenticate: true
    field :add_reply_to_comment, mutation: Mutations::AddReplyToComment, authenticate: true
    field :cast_vote_on_comment, mutation: Mutations::CastVoteOnComment, authenticate: true
    field :provide_answer_to_poll_question, mutation: Mutations::ProvideAnswerToPollQuestion, authenticate: true
    field :start_debate, mutation: Mutations::StartDebate, authenticate: true
    field :submit_proposal, mutation: Mutations::SubmitProposal, authenticate: true
    field :support_proposal, mutation: Mutations::SupportProposal, authenticate: true
  end
end
