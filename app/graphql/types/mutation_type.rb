module Types
  class MutationType < Types::BaseObject
    field :answer, mutation: Mutations::Answer, authenticate: true
  end
end
