class Community < ActiveRecord::Base
  belongs_to :communitable, polymorphic: true
  has_many :topics

  def participants
    users_participants = users_who_commented +
                         users_who_topics_author +
                         author_from_community
    users_participants.uniq
  end

  def communitable_key
    communitable_type.split("::").last.underscore
  end

  # @deprecated Please use {#communitable} instead
  def proposal
    warn "[DEPRECATION] `Community#proposal` is deprecated. " +
         "Please use `Community#communitable` instead."
    communitable
  end

  # @deprecated Please use {#communitable} instead
  def investment
    warn "[DEPRECATION] `Community#investment` is deprecated. " +
         "Please use `Community#communitable` instead."
    communitable
  end

  private

  def users_who_commented
    topics_ids = topics.pluck(:id)
    query = "comments.commentable_id IN (?)and comments.commentable_type = 'Topic'"
    User.by_comments(query, topics_ids)
  end

  def users_who_topics_author
    author_ids = topics.pluck(:author_id)
    User.by_authors(author_ids)
  end

  def author_from_community
    User.where(id: communitable&.author_id)
  end

end
