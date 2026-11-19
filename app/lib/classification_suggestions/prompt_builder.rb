module ClassificationSuggestions
  class PromptBuilder
    TITLE_MAX_LENGTH = 80
    SUMMARY_MAX_LENGTH = 200
    DESCRIPTION_MAX_LENGTH = 6000

    def initialize(title:, summary:, description:, locale:, max_tags:,
                   max_sdgs:, sdg_enabled:, selected_tags: [], selected_sdgs: [])
      @title = title.to_s
      @summary = summary.to_s
      @description = description.to_s
      @locale = locale
      @max_tags = max_tags
      @max_sdgs = max_sdgs
      @sdg_enabled = sdg_enabled
      @selected_tags = Array(selected_tags)
      @selected_sdgs = Array(selected_sdgs)
    end

    def system_instructions
      parts = [base_prompt]
      parts << sdg_appendix if @sdg_enabled
      parts << request_params
      parts.join("\n")
    end

    def user_message
      prompts.fetch("classification_suggestion_user") % {
        title: truncate(@title, TITLE_MAX_LENGTH),
        summary: truncate(@summary, SUMMARY_MAX_LENGTH),
        description: truncate(@description, DESCRIPTION_MAX_LENGTH),
        selected_categories: selected_category_lines,
        selected_tags: selected_free_form_tag_lines,
        selected_sdgs: @selected_sdgs.join("\n")
      }
    end

    private

      def base_prompt
        prompts.fetch("classification_suggestion_prompt") % {
          available_categories: available_category_lines
        }
      end

      def sdg_appendix
        prompts.fetch("classification_suggestion_sdg_system_appendix") % {
          available_sdgs: available_sdg_lines
        }
      end

      def request_params
        parts = [
          prompts.fetch("classification_suggestion_request_params") % {
            locale: @locale,
            max_tags: @max_tags
          }
        ]
        if @sdg_enabled
          parts << prompts.fetch("classification_suggestion_request_params_sdg") % {
            max_sdgs: @max_sdgs
          }
        end
        parts.join("\n")
      end

      def available_category_lines
        available_category_names.join("\n")
      end

      def available_category_names
        @available_category_names ||= Tag.category.order(:name).pluck(:name)
      end

      def available_sdg_lines
        lines = []
        SDG::Goal.order(:code).includes(:targets, :local_targets).each do |goal|
          lines << "#{goal.code} | #{goal.title}"
          (goal.targets + goal.local_targets).sort.each do |target|
            lines << "#{target.code} | #{target.title}"
          end
        end
        lines.join("\n")
      end

      def selected_category_lines
        split_selected_tags.fetch(:categories).join("\n")
      end

      def selected_free_form_tag_lines
        split_selected_tags.fetch(:tags).join("\n")
      end

      def split_selected_tags
        @split_selected_tags ||=
          begin
            categories = []
            tags = []

            @selected_tags.each do |name|
              canonical = category_names_by_key[name.downcase]
              if canonical
                categories << canonical
              else
                tags << name
              end
            end

            {
              categories: categories.uniq,
              tags: tags.uniq(&:downcase)
            }
          end
      end

      def category_names_by_key
        @category_names_by_key ||= available_category_names.index_by(&:downcase)
      end

      def truncate(value, length)
        value.truncate(length, omission: "")
      end

      def prompts
        @prompts ||= ::Llm::Config.prompts
      end
  end
end
