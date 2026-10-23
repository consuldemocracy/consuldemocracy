require "rails_helper"

describe Shared::TagListComponent do
  it "is not rendered when there are no tags" do
    render_inline Shared::TagListComponent.new(Proposal.new, limit: nil)

    expect(page).not_to be_rendered
  end

  it "renders the see more link when there are more tags than the limit" do
    proposal = create(:proposal)
    5.times { create(:tagging, tag: create(:tag), taggable: proposal) }

    render_inline Shared::TagListComponent.new(proposal, limit: 3)

    expect(page).to have_link exact_text: "2+", title: "2 more tags", class: "more-list"
  end
end
