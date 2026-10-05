require "rails_helper"

describe Shared::TagListComponent do
  it "is not rendered when there are no tags" do
    render_inline Shared::TagListComponent.new(Proposal.new, limit: nil)

    expect(page).not_to be_rendered
  end
end
