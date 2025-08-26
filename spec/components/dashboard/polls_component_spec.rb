require "rails_helper"

describe Dashboard::PollsComponent do
  it "is not rendered when there aren't any polls" do
    render_inline Dashboard::PollsComponent.new(Poll.none)

    expect(page).not_to be_rendered
  end
end
