class Tagging < ActsAsTaggableOn::Tagging

  def self.public_columns
    ["tag_id",
     "taggable_id",
     "taggable_type"]
  end

  def public?
    return false unless ["Proposal", "Debate"].include? (taggable_type)
    return false if taggable.try(:hidden?)
    return false unless Tag.find(tag_id).try(:public?)
    return true
  end

end