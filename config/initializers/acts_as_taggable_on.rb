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

    include Graphqlable

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

    def self.category_names
      Tag.where("kind = 'category'").pluck(:name)
    end

    def self.spending_proposal_tags
      ActsAsTaggableOn::Tag.where('taggings.taggable_type' => 'SpendingProposal').includes(:taggings).order(:name).uniq
    end

    def self.public_for_api
      find_by_sql(%|
        SELECT *
        FROM tags
        WHERE (tags.kind IS NULL OR tags.kind = 'category') AND tags.id IN (
          SELECT tag_id
          FROM (
            SELECT COUNT(taggings.id) AS taggings_count, tag_id
            FROM ((taggings FULL OUTER JOIN proposals ON taggable_type = 'Proposal' AND taggable_id = proposals.id) FULL OUTER JOIN debates ON taggable_type = 'Debate' AND taggable_id = debates.id)
            WHERE (taggable_type = 'Proposal' AND proposals.hidden_at IS NULL) OR (taggable_type = 'Debate' AND debates.hidden_at IS NULL)
            GROUP BY tag_id
          ) AS tag_taggings_count_relation
          WHERE taggings_count > 0
        )
      |)
    end

    def self.graphql_field_name
      :tag
    end

    def self.graphql_pluralized_field_name
      :tags
    end

    def self.graphql_type_name
      'Tag'
    end

    private
      def custom_counter_field_name_for(taggable_type)
        "#{taggable_type.underscore.pluralize}_count"
      end
  end

end
