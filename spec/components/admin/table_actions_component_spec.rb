require "rails_helper"

describe Admin::TableActionsComponent, type: :component do
  let(:record) { create(:banner) }

  before do
    allow(ViewComponent::Base).to receive(:test_controller).and_return("Admin::BaseController")
  end

  it "renders links to edit and destroy a record by default" do
    render_inline Admin::TableActionsComponent.new(record)

    expect(page).to have_css "a", count: 2
    expect(page).to have_css "a[href*='edit']", text: "Edit"
    expect(page).to have_css "a[data-method='delete']", text: "Delete"
  end

  context "actions parameter is passed" do
    it "renders a link to edit a record if passed" do
      render_inline Admin::TableActionsComponent.new(record, actions: [:edit])

      expect(page).to have_link "Edit"
      expect(page).not_to have_link "Delete"
    end

    it "renders a link to destroy a record if passed" do
      render_inline Admin::TableActionsComponent.new(record, actions: [:destroy])

      expect(page).to have_link "Delete"
      expect(page).not_to have_link "Edit"
    end
  end

  it "allows custom texts for actions" do
    render_inline Admin::TableActionsComponent.new(record, edit_text: "change", destroy_text: "annihilate")

    expect(page).to have_link "annihilate"
    expect(page).to have_link "change"
    expect(page).not_to have_link "Delete"
    expect(page).not_to have_link "Edit"
  end

  it "allows custom URLs" do
    render_inline Admin::TableActionsComponent.new(edit_path: "/myedit", destroy_path: "/mydestroy")

    expect(page).to have_link "Edit", href: "/myedit"
    expect(page).to have_link "Delete", href: "/mydestroy"
  end

  it "allows custom confirmation text" do
    render_inline Admin::TableActionsComponent.new(record, destroy_confirmation: "Are you mad? Be careful!")

    expect(page).to have_css "a[data-confirm='Are you mad? Be careful!']"
  end

  it "allows custom options" do
    render_inline Admin::TableActionsComponent.new(record, edit_options: { id: "edit_me" })

    expect(page).to have_css "a#edit_me"
  end

  it "allows custom content" do
    render_inline Admin::TableActionsComponent.new(record) do
      "<a href='/'>Main</a>".html_safe
    end

    expect(page).to have_css "a", count: 3
    expect(page).to have_link "Main", href: "/"
    expect(page).to have_link "Edit"
    expect(page).to have_link "Delete"
  end

  context "different namespace" do
    before do
      allow(ViewComponent::Base).to receive(:test_controller).and_return("SDGManagement::BaseController")
    end

    it "generates links to different namespaces" do
      render_inline Admin::TableActionsComponent.new(create(:sdg_local_target))

      expect(page).to have_css "a", count: 2
      expect(page).to have_css "a[href^='/sdg_management/'][href*='edit']", text: "Edit"
      expect(page).to have_css "a[href^='/sdg_management/'][data-method='delete']", text: "Delete"
    end
  end
end
