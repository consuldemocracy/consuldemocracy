DebateType = GraphQL::ObjectType.define do
  name "Debate"
  description "A single debate entry with associated info"

  interfaces([CommentableInterface])

  # Expose fields associated with Debate model
  field :id, !types.ID, "The id of this debate"
  field :title, types.String, "The title of this debate"
  field :description, types.String, "The description of this debate"
  field :author_id, types.Int, "ID of the author of this proposal"
  field :created_at, types.String, "Date when this debate was created"
  field :updated_at, types.String, "Date when this debate was edited"
  field :flags_count, types.Int, "Number of flags of this debate"
  field :cached_votes_total, types.Int, "The total number of votes of this debate"
  field :cached_votes_up, types.Int, "The total number of upvotes of this debate"
  field :cached_votes_down, types.Int, "The total number of downvotes of this debate"
  field :comments_count, types.Int, "Number of comments on this debate"
  field :geozone_id, types.Int, "ID of the geozone affected by this debate"

  # Linked resources
  field :author, UserType, "Author of this debate"
  field :comments, !types[!CommentType], "Comments in this debate"
  field :geozone, GeozoneType, "Geozone affected by this debate"
end
