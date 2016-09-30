CommentableInterface = GraphQL::InterfaceType.define do
  name "Commentable"

  field :id, !types.ID, "ID of the commentable"
  field :title, types.String, "The title of this commentable"
  field :description, types.String, "The description of this commentable"
  field :author_id, types.Int, "ID of the author of this commentable"
  field :comments_count, types.Int, "Number of comments on this commentable"

  # Linked resources
  field :author, UserType, "Author of this commentable"
  field :comments, !types[!CommentType], "Comments in this commentable"
  field :geozone, GeozoneType, "Geozone affected by this commentable"
end
