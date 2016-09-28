QueryRoot = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"

  field :proposal do
    type ProposalType
    description "Find a Proposal by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      Proposal.find(arguments["id"])
    }
  end
end
