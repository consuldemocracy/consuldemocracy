class Taggable::FieldsComponent < ApplicationComponent
  attr_reader :form, :i18n_namespace, :autocomplete, :ai_suggestions

  def initialize(form, i18n_namespace:, categories: nil, autocomplete: true, ai_suggestions: false)
    @form = form
    @i18n_namespace = i18n_namespace
    @categories = categories
    @autocomplete = autocomplete
    @ai_suggestions = ai_suggestions
  end

  def categories
    @categories ||= Tag.category.order(:name)
  end

  private

    def category_name(category)
      category.respond_to?(:name) ? category.name : category.to_s
    end

    def category_selected?(name)
      form.object.tag_list.include?(name)
    end

    def tag_list_value
      form.object.tag_list.to_a.join(",")
    end

    def tag_list_data
      data = { remove_tag_text: t("sdg.related_list_selector.remove_tag") }
      data[:suggestions_url] = suggest_tags_path if autocomplete
      data
    end

    def tags_label
      t("#{i18n_namespace}.tags_label")
    end

    def tags_instructions
      t("#{i18n_namespace}.tags_instructions")
    end

    def tags_placeholder
      t("#{i18n_namespace}.tags_placeholder")
    end

    def tag_category_label
      t("#{i18n_namespace}.tag_category_label")
    end

    def show_ai_suggestions?
      ai_suggestions &&
        ::Llm::Config.configured? &&
        Setting["llm.use_ai_classification_suggestions"].present?
    end

    def suggest_button_data
      data = { resource_type: form.object.class.name }
      data[:resource_id] = form.object.id if form.object.persisted?
      data
    end
end
