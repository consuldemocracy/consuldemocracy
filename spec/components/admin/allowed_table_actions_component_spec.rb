require "rails_helper"

describe Admin::AllowedTableActionsComponent, :admin do
  before do
    allow_any_instance_of(Admin::AllowedTableActionsComponent).to receive(:can?).and_return true
  end
  let(:record) { create(:banner, title: "Important!") }

  it "renders edit and destroy actions by default if they're allowed" do
    component = Admin::AllowedTableActionsComponent.new(record)

    render_inline component

    expect(page).to have_link count: 1
    expect(page).to have_link "Edit"
    expect(page).to have_button count: 1
    expect(page).to have_button "Delete"
  end

  it "accepts an actions parameter" do
    render_inline Admin::AllowedTableActionsComponent.new(record, actions: [:edit])

    expect(page).to have_link "Edit"
    expect(page).not_to have_button "Delete"
  end

  it "accepts custom options" do
    render_inline Admin::AllowedTableActionsComponent.new(record, edit_text: "change", edit_path: "/myedit")

    expect(page).to have_link "change", href: "/myedit"
  end

  it "accepts custom content" do
    render_inline Admin::AllowedTableActionsComponent.new(record) do
      "<a href='/'>Main</a>".html_safe
    end

    expect(page).to have_link count: 2
    expect(page).to have_link "Main", href: "/"
    expect(page).to have_link "Edit"

    expect(page).to have_button count: 1
    expect(page).to have_button "Delete"
  end

  it "only renders the allowed actions" do
    component = Admin::AllowedTableActionsComponent.new(record)
    allow(component).to receive(:can?).with(:edit, record).and_return true
    allow(component).to receive(:can?).with(:destroy, record).and_return false

    render_inline component

    expect(page).to have_link "Edit"
    expect(page).not_to have_button "Delete"
  end
end
