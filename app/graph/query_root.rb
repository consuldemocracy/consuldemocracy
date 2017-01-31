QueryRoot = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"

  field :proposal do
    type TYPE_BUILDER.types[Proposal]
    description "Find a Proposal by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      Proposal.find(arguments["id"])
    }
  end

  field :proposals do
    type types[TYPE_BUILDER.types[Proposal]]
    description "Find all Proposals"
    resolve -> (object, arguments, context) {
      Proposal.all
    }
  end

  field :debate do
    type TYPE_BUILDER.types[Debate]
    description "Find a Debate by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      Debate.find(arguments["id"])
    }
  end

  field :debates do
    type types[TYPE_BUILDER.types[Debate]]
    description "Find all Debates"
    resolve -> (object, arguments, context) {
      Debate.all
    }
  end

  field :comment do
    type TYPE_BUILDER.types[Comment]
    description "Find a Comment by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      Comment.find(arguments["id"])
    }
  end

  field :comments do
    type types[TYPE_BUILDER.types[Comment]]
    description "Find all Comments"
    resolve -> (object, arguments, context) {
      Comment.all
    }
  end

  field :user do
    type TYPE_BUILDER.types[User]
    description "Find a User by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      User.find(arguments["id"])
    }
  end

end
