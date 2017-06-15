module HasPublicAuthor
  def public_author
    self.author.public_activity? ? self.author : nil
  end
end
