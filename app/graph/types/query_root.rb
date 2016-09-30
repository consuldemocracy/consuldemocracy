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

  field :proposals do
    type !types[!ProposalType]
    description "Find all Proposals"
    resolve -> (object, arguments, context) {
      Proposal.all
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

  field :comments do
    type !types[!CommentType]
    description "Find all Comments"
    resolve -> (object, arguments, context) {
      Comment.all
    }
  end
end
