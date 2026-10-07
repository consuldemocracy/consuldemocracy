require "rails_helper"

describe Taggable::FieldsComponent do
  let(:proposal) { create(:proposal, tag_list: "existing") }
  let(:form) { ConsulFormBuilder.new(:proposal, proposal, ApplicationController.new.view_context, {}) }

  before do
    create(:tag, :category, name: "Education")
    create(:tag, :category, name: "Health")
  end

  describe "category buttons" do
    it "renders category buttons when categories are present" do
      component = Taggable::FieldsComponent.new(
        form,
        categories: Tag.where(name: "Education"),
        i18n_namespace: "proposals.form"
      )

      render_inline component

      expect(page).to have_css "#category_tags"
      expect(page).to have_button class: "add-tag", count: 1
      expect(page).to have_button "Education", class: "add-tag"
      expect(page).to have_content "Categories"
    end

    it "does not render category buttons when categories are empty" do
      component = Taggable::FieldsComponent.new(
        form,
        categories: [],
        i18n_namespace: "debates.form"
      )

      render_inline component

      expect(page).not_to have_css "#category_tags"
      expect(page).to have_css "label", text: "Tags"
      expect(page).to have_content "Tag this debate."
    end

    it "defaults categories to Tag.category when omitted" do
      component = Taggable::FieldsComponent.new(form, i18n_namespace: "proposals.form")

      render_inline component

      expect(page).to have_button class: "add-tag", count: 2
      expect(page).to have_button "Education", class: "add-tag"
      expect(page).to have_button "Health", class: "add-tag"
    end
  end

  it "adds autocomplete attributes when autocomplete is enabled" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form",
      autocomplete: true
    )

    render_inline component

    expect(page).to have_css "input.js-tag-list.tag-autocomplete[data-js-url]"
  end

  it "omits autocomplete attributes when autocomplete is disabled" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: ["Health"],
      i18n_namespace: "proposals.form",
      autocomplete: false
    )

    render_inline component

    expect(page).to have_css "input.js-tag-list"
    expect(page).not_to have_css "input.tag-autocomplete"
    expect(page).not_to have_css "input[data-js-url]"
    expect(page).to have_button "Health", class: "add-tag"
  end

  it "renders string category names" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: ["Custom category"],
      i18n_namespace: "proposals.form",
      autocomplete: false
    )

    render_inline component

    expect(page).to have_button "Custom category", class: "add-tag"
  end

  it "uses labels from the given i18n namespace" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: ["Health"],
      i18n_namespace: "proposals.form",
      autocomplete: false
    )

    render_inline component

    expect(page).to have_css "label", text: "Tags"
    expect(page).to have_content "Categories"
  end

  it "prefills the tag list from the form object" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form"
    )

    render_inline component

    expect(page).to have_field "Tags", with: "existing"
  end
end
