require "rails_helper"

describe Admin::HiddenTableActionsComponent, type: :component do
  let(:record) { create(:user) }
  let(:component) { Admin::HiddenTableActionsComponent.new(record) }

  it "renders links to restore and confirm hide" do
    render_inline component

    expect(page).to have_css "a", count: 2
    expect(page).to have_css "a[href*='restore'][data-method='put']", text: "Restore"
    expect(page).to have_css "a[href*='confirm_hide'][data-method='put']", text: "Confirm moderation"
  end
end
