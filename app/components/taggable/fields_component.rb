class Taggable::FieldsComponent < ApplicationComponent
  attr_reader :form, :i18n_namespace, :autocomplete

  def initialize(form, i18n_namespace:, categories: nil, autocomplete: true)
    @form = form
    @i18n_namespace = i18n_namespace
    @categories = categories
    @autocomplete = autocomplete
  end

  def categories
    @categories ||= Tag.category.order(:name)
  end

  private

    def category_name(category)
      category.respond_to?(:name) ? category.name : category.to_s
    end

    def tag_list_classes
      classes = ["js-tag-list"]
      classes << "tag-autocomplete" if autocomplete
      classes.join(" ")
    end

    def tag_list_data
      autocomplete ? { js_url: suggest_tags_path } : {}
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
end
