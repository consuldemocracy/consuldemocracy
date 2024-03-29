require "rails_helper"

describe Shared::AvatarComponent do
  it "does not contain redundant text already present around it" do
    render_inline Shared::AvatarComponent.new(double(id: 1, name: "Johnny"))

    expect(page).to have_css "img", count: 1
    expect(page).to have_css "img[alt='']"
  end
end
