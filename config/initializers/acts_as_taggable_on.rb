ActsAsTaggableOn.setup do |config|
  # This works because the classes where the base class is a concern, Tag and Tagging
  # are autoloaded, and won't be started until after the initializers run. The value
  # must be a String, as the Rails Zeitwerk autoloader will not allow models to be
  # referenced at initialization time.
  #
  # config.base_class = "ApplicationRecord"
end

Rails.application.reloader.to_prepare do
  ActsAsTaggableOn::Tag.class_eval do
    include Graphqlable
  end
end

module ActsAsTaggableOn
  Tagging.class_eval do
    after_create :increment_tag_custom_counter
    after_destroy :touch_taggable, :decrement_tag_custom_counter

    scope :public_for_api, -> do
      where(
        tag: Tag.where(kind: [nil, "category"]),
        taggable: [Debate.public_for_api, Proposal.public_for_api]
      )
    end

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
    scope :category, -> { where(kind: "category") }

    def category?
      kind == "category"
    end

    scope :public_for_api, -> do
      where(
        kind: [nil, "category"],
        id: Tagging.public_for_api.distinct.pluck(:tag_id)
      )
    end

    include PgSearch::Model

    pg_search_scope :pg_search, against: :name,
                                using: {
                                  tsearch: { prefix: true }
                                },
                                ignoring: :accents

    def self.search(term)
      pg_search(term)
    end

    def increment_custom_counter_for(taggable_type)
      Tag.increment_counter(custom_counter_field_name_for(taggable_type), id)
    end

    def decrement_custom_counter_for(taggable_type)
      Tag.decrement_counter(custom_counter_field_name_for(taggable_type), id)
    end

    def self.category_names
      Tag.category.pluck(:name)
    end

    private

      def custom_counter_field_name_for(taggable_type)
        "#{taggable_type.tableize.tr("/", "_")}_count"
      end
  end
end
