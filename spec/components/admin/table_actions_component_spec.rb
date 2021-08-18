require "rails_helper"

describe Admin::TableActionsComponent, controller: Admin::BaseController do
  let(:record) { create(:banner, title: "Important!") }

  it "renders edit and destroy actions by default" do
    render_inline Admin::TableActionsComponent.new(record)

    expect(page).to have_link count: 1
    expect(page).to have_css "a[href*='edit']", exact_text: "Edit"
    expect(page).to have_css "a[aria-label='Edit Important!']"

    expect(page).to have_button count: 1
    expect(page).to have_css "button[aria-label='Delete Important!']", exact_text: "Delete"
    expect(page).to have_css "input[name='_method'][value='delete']", visible: :hidden
  end

  context "actions parameter is passed" do
    it "renders a link to edit a record if passed" do
      render_inline Admin::TableActionsComponent.new(record, actions: [:edit])

      expect(page).to have_link "Edit"
      expect(page).not_to have_button "Delete"
    end

    it "renders a button to destroy a record if passed" do
      render_inline Admin::TableActionsComponent.new(record, actions: [:destroy])

      expect(page).to have_button "Delete"
      expect(page).not_to have_link "Edit"
    end
  end

  it "allows custom texts for actions" do
    render_inline Admin::TableActionsComponent.new(record, edit_text: "change", destroy_text: "annihilate")

    expect(page).to have_button "annihilate"
    expect(page).to have_link "change"
    expect(page).not_to have_button "Delete"
    expect(page).not_to have_link "Edit"
  end

  it "allows custom URLs" do
    render_inline Admin::TableActionsComponent.new(record, edit_path: "/myedit", destroy_path: "/mydestroy")

    expect(page).to have_link "Edit", href: "/myedit"
    expect(page).to have_css "form[action='/mydestroy']", exact_text: "Delete"
  end

  it "allows custom confirmation text" do
    render_inline Admin::TableActionsComponent.new(record, destroy_confirmation: "Are you mad? Be careful!")

    expect(page).to have_css "button[data-confirm='Are you mad? Be careful!']"
  end

  it "allows custom options" do
    render_inline Admin::TableActionsComponent.new(record, edit_options: { id: "edit_me" })

    expect(page).to have_css "a#edit_me"
  end

  it "allows custom content" do
    render_inline Admin::TableActionsComponent.new(record) do
      "<a href='/'>Main</a>".html_safe
    end

    expect(page).to have_css "a", count: 2
    expect(page).to have_link "Main", href: "/"
    expect(page).to have_link "Edit"

    expect(page).to have_button count: 1
    expect(page).to have_button "Delete"
  end

  context "different namespace" do
    it "generates actions to different namespaces", controller: SDGManagement::BaseController do
      render_inline Admin::TableActionsComponent.new(create(:sdg_local_target))

      expect(page).to have_link count: 1
      expect(page).to have_css "a[href^='/sdg_management/'][href*='edit']", exact_text: "Edit"

      expect(page).to have_button count: 1
      expect(page).to have_css "form[action^='/sdg_management/']", exact_text: "Delete"
    end
  end
end
