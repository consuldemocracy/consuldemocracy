class Community < ActiveRecord::Base
  has_one :proposal
  has_one :investment, class_name: Budget::Investment
  has_many :topics

  def participants
    users_participants = users_who_commented_by +
                         users_who_topics_author_by +
                         author_from_community
    users_participants.uniq
  end

  def from_proposal?
    self.proposal.present?
  end

  private

  def users_who_commented_by
    topics_ids = topics.pluck(:id)
    query = "comments.commentable_id IN (?)and comments.commentable_type = 'Topic'"
    User.by_comments(query, topics_ids)
  end

  def users_who_topics_author_by
    author_ids = topics.pluck(:author_id)
    User.by_authors(author_ids)
  end

  def author_from_community
    if from_proposal?
      User.where(id: proposal.author_id)
    else
      investment = Budget::Investment.where(community_id: id).first
      User.where(id: investment.author_id)
    end
  end

end
