require "rails_helper"

describe Relationable::RelatedListComponent do
  let(:proposal) { create(:proposal) }
  let(:user_proposal) { create(:proposal, title: "I am user related") }
  let(:component) { Relationable::RelatedListComponent.new(proposal) }

  before do
    create(:related_content, parent_relationable: proposal, child_relationable: user_proposal)
  end

  it "displays user content" do
    render_inline component

    expect(page).to have_css "li", count: 1
    expect(page).to have_content "I am user related"
  end
end
