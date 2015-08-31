ActsAsTaggableOn::Tagging.class_eval do
  after_destroy :touch_taggable

  def touch_taggable
    taggable.touch
  end

end