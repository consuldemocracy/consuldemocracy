require "rails_helper"

describe Admin::ActionComponent do
  it "includes an HTML class for the action" do
    render_inline Admin::ActionComponent.new(:edit, double, path: "/")

    expect(page).to have_css "a.edit-link"
  end
end
