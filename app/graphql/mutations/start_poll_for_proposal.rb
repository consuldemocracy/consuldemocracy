module Mutations
  class StartPollForProposal < BaseMutation
    argument :proposal_id, ID, required: true
    argument :attributes, Types::PollAttributes, required: true

    type Types::PollType

    def resolve(proposal_id:, attributes:)
      begin

        poll_params = attributes.to_hash.merge({
          author: context[:current_resource],
          related_id: proposal_id,
          related_type: "Proposal"
        })

        poll = Poll.new(poll_params)

        poll.questions.each do |question|
          question.author = context[:current_resource]
          question.proposal_id = proposal_id
        end

        poll.save!
        poll
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
