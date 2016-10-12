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

  connection :proposals, ProposalType.connection_type do
    description "Find all Proposals"
    resolve -> (object, arguments, context) {
      Proposal.all
    }
  end

  field :debate do
    type DebateType
    description "Find a Debate by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      Debate.find(arguments["id"])
    }
  end

  connection :debates, DebateType.connection_type do
    description "Find all Debates"
    resolve -> (object, arguments, context) {
      Debate.all
    }
  end

  field :comment do
    type CommentType
    description "Find a Comment by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      Comment.find(arguments["id"])
    }
  end

  connection :comments, CommentType.connection_type do
    description "Find all Comments"
    resolve -> (object, arguments, context) {
      Comment.all
    }
  end
end
