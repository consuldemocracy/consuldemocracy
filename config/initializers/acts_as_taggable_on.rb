module ActsAsTaggableOn

  Tagging.class_eval do

    after_create :increment_tag_custom_counter
    after_destroy :touch_taggable, :decrement_tag_custom_counter

    def touch_taggable
      taggable.touch if taggable.present?
    end

    def increment_tag_custom_counter
      tag.increment_custom_counter_for(taggable_type)
    end

    def decrement_tag_custom_counter
      tag.decrement_custom_counter_for(taggable_type)
    end
  end

  Tag.class_eval do

    def increment_custom_counter_for(taggable_type)
      Tag.increment_counter(custom_counter_field_name_for(taggable_type), id)
    end

    def decrement_custom_counter_for(taggable_type)
      Tag.decrement_counter(custom_counter_field_name_for(taggable_type), id)
    end

    def recalculate_custom_counter_for(taggable_type)
      visible_taggables = taggable_type.constantize.includes(:taggings).where('taggings.taggable_type' => taggable_type, 'taggings.tag_id' => id)

      update(custom_counter_field_name_for(taggable_type) => visible_taggables.count)
    end

    private
      def custom_counter_field_name_for(taggable_type)
        "#{taggable_type.underscore.pluralize}_count"
      end
  end

end
