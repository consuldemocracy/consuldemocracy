class Tag < ActsAsTaggableOn::Tag

  def self.public_columns_for_api
    ["name",
     "taggings_count",
     "kind"]
  end

  def public_for_api?
    [nil, "category"].include? kind
  end
end