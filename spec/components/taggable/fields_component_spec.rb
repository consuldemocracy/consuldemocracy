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
      expect(page).to have_css "input.js-tag-category[data-list-value='Education']", count: 1
      expect(page).to have_css "label", text: "Education"
      expect(page).to have_content "Categories"
    end

    it "does not render category checkboxes when categories are empty" do
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

      expect(page).to have_css "input.js-tag-category", count: 2
      expect(page).to have_css "input.js-tag-category[data-list-value='Education']"
      expect(page).to have_css "input.js-tag-category[data-list-value='Health']"
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

  it "adds suggestions url when autocomplete is enabled" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form",
      autocomplete: true
    )

    render_inline component

    expect(page).to have_css "input.js-tag-list[data-suggestions-url]"
    expect(page).to have_css "input.js-tag-list[data-remove-tag-text]"
    expect(page).not_to have_css "input.tag-autocomplete"
  end

  it "omits suggestions url when autocomplete is disabled" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: ["Health"],
      i18n_namespace: "proposals.form",
      autocomplete: false
    )

    render_inline component

    expect(page).to have_css "input.js-tag-list"
    expect(page).not_to have_css "input[data-suggestions-url]"
    expect(page).to have_css "input.js-tag-category[data-list-value='Health']"
  end

  it "renders string category names" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: ["Custom category"],
      i18n_namespace: "proposals.form",
      autocomplete: false
    )

    render_inline component

    expect(page).to have_css "input.js-tag-category[data-list-value='Custom category']"
    expect(page).to have_css "label", text: "Custom category"
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

  it "prefills the tag list from the form object without quotes" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form"
    )

    render_inline component

    expect(page).to have_field "Tags", with: "existing"
  end

  it "quotes tag names that contain commas" do
    proposal = create(:proposal)
    proposal.tags << Tag.find_or_create_by!(name: "Culture, Leisure and Tourism")
    proposal.reload
    form = ConsulFormBuilder.new(:proposal, proposal, ApplicationController.new.view_context, {})
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form"
    )

    render_inline component

    expect(page.find("input.js-tag-list")[:value]).to eq("\"Culture, Leisure and Tourism\"")
  end

  it "wraps fields in a js-taggable-fields root" do
    component = Taggable::FieldsComponent.new(
      form,
      categories: [],
      i18n_namespace: "proposals.form"
    )

    render_inline component

    expect(page).to have_css ".js-taggable-fields input.js-tag-list"
  end
end
