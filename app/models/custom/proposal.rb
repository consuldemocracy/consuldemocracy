require_dependency Rails.root.join("app", "models", "proposal").to_s

class Proposal

  scope :proposals_by_category,     ->(tag) { joins(:taggings).joins(:tags).where("tags.kind = 'category' and taggings.taggable_type = 'Proposal' and tags.name = ?", "#{tag}") }

end
