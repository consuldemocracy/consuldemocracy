class Tagging < ActsAsTaggableOn::Tagging

  def self.public_columns_for_api
    ["tag_id",
     "taggable_id",
     "taggable_type"]
  end

  def public_for_api?
    return false unless ["Proposal", "Debate"].include? (taggable_type)
    return false if taggable.try(:hidden?)
    return false unless Tag.find(tag_id).try(:public_for_api?)
    return true
  end

end