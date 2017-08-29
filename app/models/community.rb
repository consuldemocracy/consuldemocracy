class Community < ActiveRecord::Base
  has_one :proposal
  has_one :investment
  has_many :topics

  def participants
    users_participants = users_who_commented_by(self) + users_who_topics_author_by(self)
    users_participants.uniq
  end

  def from_proposal?
    self.proposal.present?
  end

  private

  def users_who_commented_by(community)
    topics_ids = community.topics.pluck(:id)
    query = "comments.commentable_id IN (?)and comments.commentable_type = 'Topic'"
    User.by_comments(query, topics_ids)
  end

  def users_who_topics_author_by(community)
    author_ids = community.topics.pluck(:author_id)
    User.by_authors(author_ids)
  end
end
