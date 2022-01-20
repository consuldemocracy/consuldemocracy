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
        # poll = Poll.new({
        #   name: attributes
        #   starts_at: "19/01/2022",
        #   ends_at: "24/01/2022",
        #   description: "We need your opinons, m8tis and m8tiños",
        #   questions_attributes: {
        #     :"0" => {
        #       author_id: "50",
        #       proposal_id: "91",
        #       title: "What the fuck?",
        #       question_answers_attributes: {
        #         :"0" => {
        #           given_order: "2",
        #           title: "Yeah man",
        #           description: "Yes bro, indeed"
        #         },
        #         :"1" => {
        #           given_order: "3",
        #           title: "No, bre",
        #           description: "Nah nah brataniño"
        #         }
        #       }
        #     }
        #   }
        # }
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
