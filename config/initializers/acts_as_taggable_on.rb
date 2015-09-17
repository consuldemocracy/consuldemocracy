ActsAsTaggableOn::Tagging.class_eval do
  after_create :increase_custom_counter
  after_destroy :touch_taggable, :decrease_custom_counter

  def touch_taggable
    taggable.touch if taggable.present?
  end

  def increase_custom_counter
    ActsAsTaggableOn::Tag.increment_counter(custom_counter_field_name, tag_id)
  end

  def decrease_custom_counter
    ActsAsTaggableOn::Tag.decrement_counter(custom_counter_field_name, tag_id)
  end

  private

  def custom_counter_field_name
    "#{self.taggable_type.underscore.pluralize}_count"
  end


end
