class Tag < ActsAsTaggableOn::Tag

  def self.public_columns_for_api
    ["name",
     "taggings_count",
     "kind"]
  end

  def public_for_api?
    return false unless [nil, "category"].include? kind
    return false unless Proposal.tagged_with(self).present? || Debate.tagged_with(self).present?
    return true
  end
end