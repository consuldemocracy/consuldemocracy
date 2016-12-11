module HasPublicAuthor
  def public_author_id
    public_author.try(:id)
  end

  def public_author
    self.author.public_activity? ? self.author : nil
  end
end
