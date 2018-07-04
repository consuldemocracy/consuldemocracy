class Community < ActiveRecord::Base
  has_one :proposal
  has_one :investment, class_name: Budget::Investment
  has_many :topics

  def participants
    users_participants = users_who_commented +
                         users_who_topics_author +
                         response_author_from_polls_for_proposal +
                         author_from_community
    users_participants.uniq
  end

  def from_proposal?
    proposal.present?
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
    from_proposal? ? User.where(id: proposal&.author_id) : User.where(id: investment&.author_id)
  end

  def response_author_from_polls_for_proposal
    author_ids = []

    Poll.where(related: proposal).each do |poll|
      author_ids += poll.questions.pluck(:author_id)
    end
    
    User.by_authors(author_ids.uniq)
  end
end
