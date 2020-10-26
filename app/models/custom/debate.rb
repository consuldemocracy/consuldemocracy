require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate

  scope :debates_by_category,     ->(tag) { joins(:taggings).joins(:tags).where("tags.kind = 'category' and taggings.taggable_type = 'Debate' and tags.name = ?", "#{tag}") }

end
