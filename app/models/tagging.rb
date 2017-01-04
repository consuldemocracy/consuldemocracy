class Tagging < ActsAsTaggableOn::Tagging

  def self.public_columns_for_api
    ["tag_id",
     "taggable_id",
     "taggable_type"]
  end

  def public_for_api?
    return false unless ["Proposal", "Debate"].include? (taggable_type)
    return false unless taggable.present?
    return false if taggable.hidden?
    return false unless tag.present?
    return false unless Tag.find(tag_id).public_for_api?
    return true
  end

end