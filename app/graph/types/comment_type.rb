CommentType = GraphQL::ObjectType.define do
  name "Comment"
  description "A reply to a proposal, spending proposal, debate or comment"

  field :id, !types.ID, "The unique ID of this comment"
  field :commentable_id, types.Int, "ID of the resource where this comment was placed on"
  field :commentable_type, types.String, "Type of resource where this comment was placed on"
  field :body, types.String, "The body of this comment"
  field :subject, types.String, "The subject of this comment"
  field :user_id, !types.Int, "The ID of the user who made this comment"
  field :created_at, types.String, "The date this comment was posted"
  field :updated_at, types.String, "The date this comment was edited"
  field :flags_count, types.Int, "The number of flags of this comment"
  field :cached_votes_total, types.Int, "The total number of votes of this comment"
  field :cached_votes_up, types.Int, "The total number of upvotes of this comment"
  field :cached_votes_down, types.Int, "The total number of downvotes of this comment"

  # Linked resources
  field :user, !UserType, "User who made this comment"
end
