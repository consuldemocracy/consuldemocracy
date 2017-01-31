class Tag < ActsAsTaggableOn::Tag
  scope :public_for_api, -> { where("kind IS NULL OR kind = 'category'") }
end
