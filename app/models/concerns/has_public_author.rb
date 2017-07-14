module HasPublicAuthor
  def public_author
    author.public_activity? ? author : nil
  end
end
