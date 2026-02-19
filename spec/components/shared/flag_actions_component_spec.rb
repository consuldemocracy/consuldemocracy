require "rails_helper"

describe Shared::FlagActionsComponent do
  let(:flaggable) { create(:debate) }

  it "is not rendered for anonymous users" do
    render_inline Shared::FlagActionsComponent.new(flaggable)

    expect(page).not_to be_rendered
  end

  it "is not rendered for the author" do
    sign_in(flaggable.author)

    render_inline Shared::FlagActionsComponent.new(flaggable)

    expect(page).not_to be_rendered
  end

  it "is rendered for other users" do
    sign_in(User.new)

    render_inline Shared::FlagActionsComponent.new(flaggable)

    expect(page).to be_rendered
  end
end
