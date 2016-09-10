class ProposalSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :question, :external_url, :flags_count,
    :comments_count, :responsible_name, :summary, :video_url, :geozone_id

  has_many :comments, serializer: CommentSerializer do
    #link(:comments) { api_comments_path(commentable_id: object.id)}
    # hardcoded url until comments are available as a resource for the api
    link(:comments) { "api/comments?commentable_id=#{object.id}" }
  end

  #this is needed to avoid n+1, gem core devs are working to remove this necessity
  #more on: https://github.com/rails-api/active_model_serializers/issues/1325
  def comments
    object.comments.loaded ? object.comments : object.comments.none
  end
end
