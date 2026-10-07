class Proposals::ProposalComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def proposal_json
    proposal.as_json(only: [], methods: fields)
  end

  private

    def fields
      graphql_fields + [:public_created_at]
    end

    def graphql_fields
      Types::ProposalType.fields.keys.select do |field|
        proposal.has_attribute?(field)
      end
    end
end
