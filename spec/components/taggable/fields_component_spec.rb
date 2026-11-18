require "rails_helper"

describe Taggable::FieldsComponent do
  let(:proposal) { create(:proposal, tag_list: "existing") }
  let(:form) { ConsulFormBuilder.new(:proposal, proposal, ApplicationController.new.view_context, {}) }

  before do
    create(:tag, :category, name: "Education")
    create(:tag, :category, name: "Health")
  end

  describe "category checkboxes" do
    it "renders category checkboxes when categories are present" do
      component = Taggable::FieldsComponent.new(
        form,
        categories: Tag.where(name: "Education"),
        i18n_namespace: "proposals.form"
      )

      render_inline component

      expect(page).to have_css "#category_tags"
      expect(page).to have_css "input[type='checkbox'][data-list-value='Education']", count: 1
      expect(page).to have_css "label", text: "Education"
      expect(page).to have_css "legend", text: "Categories and tags"
      expect(page).not_to have_css "label", exact_text: "Categories"
    end

    it "renders categories before the custom tags field" do
      component = Taggable::FieldsComponent.new(
        form,
        categories: Tag.where(name: "Education"),
        i18n_namespace: "proposals.form"
      )

      render_inline component

      expect(page).to have_css ".taggable-fields > legend:first-child", text: "Categories and tags"
      expect(page).to have_css "legend:first-child ~ #tag-list-help-text"
      expect(page).to have_css "#tag-list-help-text ~ #category_tags"
      expect(page).to have_css "#category_tags > legend.show-for-sr", exact_text: "Categories"
      expect(page).to have_css "#category_tags ~ label.show-for-sr", exact_text: "Tags"
      expect(page).to have_css "#category_tags ~ input[type='text']"
      expect(page).not_to have_css "label", exact_text: "Categories"
    end

    it "does not render category checkboxes when categories are empty" do
      component = Taggable::FieldsComponent.new(
        form,
        categories: [],
        i18n_namespace: "debates.form"
      )

      render_inline component

      expect(page).not_to have_css "#category_tags"
      expect(page).not_to have_css "legend", text: "Categories and tags"
      expect(page).to have_css "fieldset.taggable-fields > legend", text: "Tags"
      expect(page).to have_css "label.show-for-sr", exact_text: "Tags"
      expect(page).to have_content "Tag this debate. You can choose from proposed categories or add your own"
    end

    it "defaults categories to Tag.category when omitted" do
      component = Taggable::FieldsComponent.new(form, i18n_namespace: "proposals.form")

      render_inline component

      expect(page).to have_css "input[type='checkbox']", count: 2
      expect(page).to have_css "input[type='checkbox'][data-list-value='Education']"
      expect(page).to have_css "input[type='checkbox'][data-list-value='Health']"
    end

    it "uses debate translations when rendering categories for debates" do
      debate = create(:debate, tag_list: "Education")
      debate_form = ConsulFormBuilder.new(:debate, debate, ApplicationController.new.view_context, {})
      component = Taggable::FieldsComponent.new(debate_form, i18n_namespace: "debates.form")

      render_inline component

      expect(page).to have_css "#category_tags"
      expect(page).to have_checked_field "Education"
      expect(page).to have_css "legend", text: "Categories and tags"
      expect(page).to have_content "Tag this debate. You can choose from proposed categories or add your own"
      expect(page).to have_css "#tag-list-help-text ~ #category_tags"
      expect(page).not_to have_css "label", exact_text: "Categories"
    end

    it "pre-checks categories already in the tag list" do
      proposal = create(:proposal, tag_list: "Education")
      form = ConsulFormBuilder.new(:proposal, proposal, ApplicationController.new.view_context, {})
      component = Taggable::FieldsComponent.new(
        form,
        categories: Tag.where(name: "Education"),
        i18n_namespace: "proposals.form"
      )

      render_inline component

      expect(page).to have_checked_field "Education"
    end
  end

  it "preloads tag suggestions when autocomplete is enabled" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form",
      autocomplete: true
    )

    render_inline component

    suggestions = page.find("input[type='text']")["data-suggestions-list"]

    expect(JSON.parse(suggestions)).to match_array ["Education", "Health", "existing"]
    expect(page).to have_css "input[type='text'][data-remove-tag-text]"
    expect(page).not_to have_css "input[data-suggestions-url]"
    expect(page).not_to have_css "input.tag-autocomplete"
  end

  it "omits suggestions when autocomplete is disabled" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: ["Health"],
      i18n_namespace: "proposals.form",
      autocomplete: false
    )

    render_inline component

    expect(page).to have_css "input[type='text']"
    expect(page).not_to have_css "input[data-suggestions-list]"
    expect(page).not_to have_css "input[data-suggestions-url]"
    expect(page).to have_css "input[type='checkbox'][data-list-value='Health']"
  end

  it "renders string category names" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: ["Custom category"],
      i18n_namespace: "proposals.form",
      autocomplete: false
    )

    render_inline component

    expect(page).to have_css "input[type='checkbox'][data-list-value='Custom category']"
    expect(page).to have_css "label", text: "Custom category"
  end

  it "shows how to enter tags in a hint instead of a placeholder" do
    component = Taggable::FieldsComponent.new(form, categories: ["Health"], i18n_namespace: "proposals.form")

    render_inline component

    instructions = "Tag this proposal. You can choose from proposed categories or add your own"
    entry_hint = "Enter the tags you would like to use, separated by commas (',')"

    expect(page).to have_css "#tag-list-help-text", text: instructions
    expect(page).to have_css "#proposal_tag_list_help_text", text: entry_hint
    expect(page.find("input[type='text']")["aria-describedby"]).to eq "proposal_tag_list_help_text"
    expect(page).not_to have_css "input[placeholder]"
  end

  it "prefills the tag list from the form object without quotes" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form"
    )

    render_inline component

    expect(page).to have_field "Tags", with: "existing"
  end

  it "wraps fields in a taggable-fields root" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form"
    )

    render_inline component

    expect(page).to have_css "fieldset.taggable-fields input[type='text']"
  end

  describe "classification suggestions" do
    before do
      Setting["llm.provider"] = nil
      Setting["llm.model"] = nil
      Setting["llm.use_ai_classification_suggestions"] = nil
    end

    it "does not render suggestions UI when ai_suggestions is disabled" do
      component = Taggable::FieldsComponent.new(
        form,
        categories: [],
        i18n_namespace: "proposals.form",
        ai_suggestions: false
      )

      render_inline component

      expect(page).not_to have_css ".suggest-classification"
      expect(page).not_to have_css ".classification-suggestions-tags"
    end

    it "renders suggest button, suggestions panel, and suggestion template when enabled" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
      Setting["llm.use_ai_classification_suggestions"] = true

      component = Taggable::FieldsComponent.new(
        form,
        categories: [],
        i18n_namespace: "proposals.form",
        ai_suggestions: true
      )

      render_inline component

      expect(page).to have_css "button.suggest-classification"
      expect(page).to have_css(
        "legend.taggable-fields-heading-with-suggest",
        text: "Tags"
      )
      expect(page).to have_css(
        "legend.taggable-fields-heading-with-suggest button.suggest-classification"
      )
      expect(page).to have_css ".classification-suggestions-tags.classification-suggestions.hide"
      expect(page).to have_css ".classification-suggestions-tags .classification-suggestions-body"
      expect(page).to have_css ".classification-suggestions-tags[data-close]"
      expect(page).to have_css(
        ".classification-suggestions-tags template.classification-suggestion-template",
        visible: :all
      )
    end

    it "renders suggest button beside the categories legend when categories are present" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
      Setting["llm.use_ai_classification_suggestions"] = true

      component = Taggable::FieldsComponent.new(
        form,
        categories: Tag.where(name: "Education"),
        i18n_namespace: "proposals.form",
        ai_suggestions: true
      )

      render_inline component

      expect(page).to have_css(
        "legend.taggable-fields-heading-with-suggest",
        text: "Categories and tags"
      )
      expect(page).to have_css(
        "legend.taggable-fields-heading-with-suggest button.suggest-classification"
      )
      expect(page).to have_css "button.suggest-classification", count: 1
      expect(page).to have_css ".taggable-fields > legend:first-child"
      expect(page).to have_css "legend:first-child ~ #tag-list-help-text"
    end
  end
end
