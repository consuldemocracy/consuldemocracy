module MailerHelper

  def commentable_url(commentable)
    return commentable.url if commentable.respond_to?(:url)
  end

end
