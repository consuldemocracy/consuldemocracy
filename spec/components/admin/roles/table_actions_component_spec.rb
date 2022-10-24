require "rails_helper"

describe Admin::Roles::TableActionsComponent, controller: Admin::BaseController do
  let(:user) { create(:user) }

  it "renders button to add the role for new records" do
    render_inline Admin::Roles::TableActionsComponent.new(user.build_manager)

    expect(page).to have_css "form[method='post']", exact_text: "Add"
    expect(page).not_to have_css "input[name='_method']", visible: :all
  end

  it "renders button to remove the role for existing records" do
    render_inline Admin::Roles::TableActionsComponent.new(create(:manager, user: user))

    expect(page).to have_css "form[method='post']", exact_text: "Delete"
    expect(page).to have_css "input[name='_method'][value='delete']", visible: :hidden
  end
end
