require "rails_helper"

describe Admin::Roles::TableActionsComponent, type: :component do
  let(:user) { create(:user) }

  before do
    allow(ViewComponent::Base).to receive(:test_controller).and_return("Admin::BaseController")
  end

  it "renders link to add the role for new records" do
    render_inline Admin::Roles::TableActionsComponent.new(user.build_manager)

    expect(page).to have_css "a[data-method='post']", text: "Add"
  end

  it "renders link to remove the role for existing records" do
    render_inline Admin::Roles::TableActionsComponent.new(create(:manager, user: user))

    expect(page).to have_css "a[data-method='delete']", text: "Delete"
  end
end
