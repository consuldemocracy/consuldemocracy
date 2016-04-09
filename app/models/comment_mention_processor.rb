class CommentMentionProcessor < MentionSystem::MentionProcessor
  ###
  # This method returns the content used to parse mentions from the mentioner object, in this case is post's content
  ###
  def extract_mentioner_content(comment)
    comment.body
  end

  ###
  # This method should return a collection (must respond to each) of mentionee objects for a given set of handles
  # In our case will be a collection of user objects
  ###
  def find_mentionees_by_handles(*handles)
    User.where(username: handles)
  end
end
