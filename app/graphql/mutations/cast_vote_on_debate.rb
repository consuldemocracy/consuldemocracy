module Mutations
  class CastVoteOnDebate < BaseMutation
    argument :debate_id, ID, required: true
    argument :vote, String, required: true, validates: { inclusion: { in: ["up", "down"] }}

    type Types::CommentType

    def resolve(debate_id:, vote:)
      begin
        debate = Debate.find debate_id
        debate.vote_by(voter: context[:current_resource], vote: vote)
        # TODO: What to return here?
        debate
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
