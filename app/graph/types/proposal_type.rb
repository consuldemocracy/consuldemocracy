ProposalType = GraphQL::ObjectType.define do
  name "Proposal"
  description "A single proposal entry returns a proposal with author, total votes and comments"
  # Expose fields associated with Proposal model
  field :id, types.ID, "The id of this proposal"
  field :title, types.String, "The title of this proposal"
  field :description, types.String, "The description of this proposal"
end
