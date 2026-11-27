class Tag < ActsAsTaggableOn::Tag
  def self.suggestion_names
    order(:name).pluck(:name)
  end
end
