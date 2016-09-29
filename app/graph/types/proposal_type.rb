ProposalType = GraphQL::ObjectType.define do
  name "Proposal"
  description "A single proposal entry returns a proposal with author, total votes and comments"
  # Expose fields associated with Proposal model
  field :id, types.ID, "The id of this proposal"
  field :title, types.String, "The title of this proposal"
  field :description, types.String, "The description of this proposal"
  field :question, types.String, "The question of this proposal"
  field :external_url, types.String, "External url related to this proposal"
  field :author_id, types.Int, "ID of the author of this proposal"
  field :flags_count, types.Int, "Number of flags of this proposal"
  field :cached_votes_up, types.Int, "Number of upvotes of this proposal"
  field :comments_count, types.Int, "Number of comments on this proposal"
  field :summary, types.String, "The summary of this proposal"
  field :video_url, types.String, "External video url related to this proposal"
  field :geozone_id, types.Int, "ID of the geozone affected by this proposal"
  field :retired_at, types.String, "Date when this proposal was retired"
  field :retired_reason, types.String, "Reason why this proposal was retired"
  field :retired_explanation, types.String, "Explanation why this proposal was retired"

  # Linked resources
  field :author, UserType, "Author of this proposal"
  field :comments, !types[!CommentType], "Comments in this proposal"
end
