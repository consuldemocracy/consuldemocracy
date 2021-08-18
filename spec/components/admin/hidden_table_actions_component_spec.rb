require "rails_helper"

describe Admin::HiddenTableActionsComponent do
  let(:record) { create(:user) }
  let(:component) { Admin::HiddenTableActionsComponent.new(record) }

  it "renders buttons to restore and confirm hide" do
    render_inline component

    expect(page).to have_button count: 2
    expect(page).to have_css "form[action*='restore']", exact_text: "Restore"
    expect(page).to have_css "form[action*='confirm_hide']", exact_text: "Confirm moderation"
    expect(page).to have_css "input[name='_method'][value='put']", visible: :hidden, count: 2
  end
end
