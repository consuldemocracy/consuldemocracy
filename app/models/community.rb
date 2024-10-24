class Community < ApplicationRecord
  has_one :proposal
  has_one :investment, class_name: "Budget::Investment"
  has_many :topics

  def participants
    users_participants = users_who_commented +
                         users_who_topics_author +
                         author_from_community
    users_participants.uniq
  end

  def from_proposal?
    proposal.present?
  end

  def latest_activity
    activity = []

    most_recent_comment = Comment.where(commentable: topics).order(updated_at: :desc).take(1).first
    activity << most_recent_comment.updated_at unless most_recent_comment.nil?

    most_recent_topic = topics.order(updated_at: :desc).take(1).first
    activity << most_recent_topic.updated_at unless most_recent_topic.nil?

    activity.max
  end

  def comments_count
    comments.count
  end

  def comments
    Comment.where(commentable: topics)
  end

  def debates_count
    topics.count
  end

  def participants_count
    participants.count
  end

  private

    def users_who_commented
      User.by_comments(topics)
    end

    def users_who_topics_author
      author_ids = topics.pluck(:author_id)
      User.by_authors(author_ids)
    end

    def author_from_community
      from_proposal? ? User.where(id: proposal&.author_id) : User.where(id: investment&.author_id)
    end
end
