module HasPublicAuthor
  def public_author
    author.public_activity? ? User.public_for_api.find_by(id: author) : nil
  end
end
