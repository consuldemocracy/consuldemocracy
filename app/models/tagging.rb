class Tagging < ActsAsTaggableOn::Tagging
  belongs_to :taggable, polymorphic: true, touch: true
end
