module Mutations
  class AddCommentToProposal < AddComment
    argument :proposal_id, ID, required: true

    type Types::CommentType

    def resolve(proposal_id:, body:)
      super(commentable_type: "Proposal", commentable_id: proposal_id, body: body)
    end
  end
end
