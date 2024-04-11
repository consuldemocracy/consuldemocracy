require "rails_helper"

describe Shared::AvatarComponent do
  let(:user) { double(id: 1, name: "Johnny") }
  let(:component) { Shared::AvatarComponent.new(user) }

  it "does not contain redundant text already present around it" do
    render_inline component

    expect(page).to have_css "svg", count: 1
    expect(page).to have_css "svg[role='img'][aria-label='']"
  end

  it "shows the initial letter of the name" do
    render_inline component

    page.find("svg") do |avatar|
      expect(avatar).to have_text "J"
      expect(avatar).not_to have_text "Johnny"
    end
  end
end
