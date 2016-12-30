class Tag < ActsAsTaggableOn::Tag

  def self.public_columns
    ["name",
     "taggings_count",
     "kind"]
  end

  def public?
    [nil, "category"].include? kind
  end
end