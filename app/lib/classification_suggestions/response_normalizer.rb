module ClassificationSuggestions
  class ResponseNormalizer
    TAG_LIST_LIMIT = 6
    MAX_CATEGORIES = 2
    MAX_SDGS = 6
    REASON_MAX_LENGTH = 280

    def initialize(parsed, selected_tags:, selected_sdgs:, sdg_enabled:)
      @parsed = parsed.is_a?(Hash) ? parsed.with_indifferent_access : {}
      @selected_tags = Array(selected_tags)
      @selected_sdgs = Array(selected_sdgs)
      @sdg_enabled = sdg_enabled
    end

    def call
      categories = suggested_categories

      {
        categories: categories,
        tags: suggested_tags(free_slots: remaining_tag_slots - categories.size),
        sdgs: suggested_sdgs
      }
    end

    private

      def suggested_categories
        limit = [MAX_CATEGORIES, remaining_tag_slots].min

        (Array(@parsed[:categories]) + llm_tags)
          .filter_map { |name| existing_category_name(name) }
          .uniq
          .reject { |name| tag_already_selected?(name) }
          .first(limit)
      end

      def suggested_tags(free_slots:)
        return [] unless free_slots.positive?

        sanitizer = TagSanitizer.new
        sanitized = llm_tags.map { |tag| sanitizer.sanitize_tag(tag.to_s.strip) }
                            .compact_blank
                            .uniq(&:downcase)

        sanitized.reject { |tag| existing_category_name(tag) || tag_already_selected?(tag) }
                 .first(free_slots)
      end

      def suggested_sdgs
        return [] unless @sdg_enabled

        remaining_sdg_slots = [MAX_SDGS - @selected_sdgs.size, 0].max

        candidates = llm_sdgs.select { |sdg| valid_sdg_codes.include?(sdg[:code]) }
                             .reject { |sdg| sdg_already_selected?(sdg[:code]) }
                             .uniq { |sdg| sdg[:code] }

        candidates.first(remaining_sdg_slots).map do |sdg|
          {
            "code" => sdg[:code],
            "reason" => sdg[:reason].to_s.strip.truncate(REASON_MAX_LENGTH)
          }
        end
      end

      def llm_tags
        Array(@parsed[:tags])
      end

      def llm_sdgs
        Array(@parsed[:sdgs]).filter_map do |sdg|
          next unless sdg.is_a?(Hash)

          data = sdg.with_indifferent_access
          code = data[:code].to_s.strip
          next if code.blank?

          { code: code, reason: data[:reason] }
        end
      end

      def remaining_tag_slots
        [TAG_LIST_LIMIT - @selected_tags.size, 0].max
      end

      def tag_already_selected?(name)
        @selected_tags.any? { |selected| selected.to_s.casecmp?(name.to_s) }
      end

      def sdg_already_selected?(code)
        @selected_sdgs.any? { |selected| selected.to_s.casecmp?(code.to_s) }
      end

      def existing_category_name(name)
        category_names_by_key[name.to_s.strip.downcase]
      end

      def category_names_by_key
        @category_names_by_key ||= Tag.category.pluck(:name).index_by(&:downcase)
      end

      def valid_sdg_codes
        @valid_sdg_codes ||= Set.new(
          SDG::Goal.pluck(:code).map(&:to_s) +
            SDG::Target.pluck(:code).map(&:to_s) +
            SDG::LocalTarget.pluck(:code).map(&:to_s)
        )
      end
  end
end
