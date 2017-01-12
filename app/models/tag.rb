class Tag < ActsAsTaggableOn::Tag

  def self.public_for_api
    where("kind IS NULL OR kind = 'category'")
  end
  
end
