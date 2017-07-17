module ActsAsTaggableOn

  Tagging.class_eval do

    after_create :increment_tag_custom_counter
    after_destroy :touch_taggable, :decrement_tag_custom_counter

    scope :public_for_api, -> do
      where(%{taggings.tag_id in (?) and
              (taggings.taggable_type = 'Debate' and taggings.taggable_id in (?)) or
              (taggings.taggable_type = 'Proposal' and taggings.taggable_id in (?))},
            Tag.where('kind IS NULL or kind = ?', 'category').pluck(:id),
            Debate.public_for_api.pluck(:id),
            Proposal.public_for_api.pluck(:id))
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

    def self.public_columns_for_api
      ["tag_id",
       "taggable_id",
       "taggable_type"]
    end

    def public_for_api?
      return false unless ["Proposal", "Debate"].include? (taggable_type)
      return false unless taggable.present?
      return false if taggable.hidden?
      return false unless tag.present?
      return false unless [nil, "category"].include? tag.kind
      return false unless taggable.public_for_api?
      return true
    end
  end

  Tag.class_eval do

    has_many :proposals, through: :taggings, source: :taggable, source_type: 'Proposal'
    has_many :debates, through: :taggings, source: :taggable, source_type: 'Debate'

    scope :category, -> { where(kind: "category") }

    def category?
      kind == "category"
    end

    include Graphqlable

    scope :public_for_api, -> do
      where('(tags.kind IS NULL or tags.kind = ?) and tags.id in (?)',
            'category',
            Tagging.public_for_api.pluck('DISTINCT taggings.tag_id'))
    end

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
      Tag.category.pluck(:name)
    end

    def self.spending_proposal_tags
      ActsAsTaggableOn::Tag.where('taggings.taggable_type' => 'SpendingProposal').includes(:taggings).order(:name).uniq
    end

    def self.public_columns_for_api
      ["id",
       "name",
       "taggings_count",
       "kind"]
    end

    def public_for_api?
      return false unless [nil, "category"].include? kind
      return false unless proposals.any?(&:public_for_api?) || debates.any?(&:public_for_api?)
      return false unless self.taggings.any?(&:public_for_api?)
      return true
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
