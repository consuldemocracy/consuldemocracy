require "rails_helper"

describe Relationable::RelatedListComponent do
  let(:proposal) { create(:proposal) }
  let(:user_proposal) { create(:proposal, title: "I am user related") }
  let(:machine_proposal) { create(:proposal, title: "I am machine related") }
  let(:component) { Relationable::RelatedListComponent.new(proposal) }

  before do
    Setting["feature.machine_learning"] = true
    Setting["machine_learning.related_content"] = true

    create(:related_content, parent_relationable: proposal, child_relationable: user_proposal)
    create(:related_content, parent_relationable: proposal,
           child_relationable: machine_proposal,
           machine_learning: true)
  end

  it "displays machine learning and user content when machine learning is enabled" do
    render_inline component

    expect(page).to have_css "li", count: 2
    expect(page).to have_content "I am machine related"
    expect(page).to have_content "I am user related"
  end

  it "displays user related content when machine learning is disabled" do
    Setting["feature.machine_learning"] = false

    render_inline component

    expect(page).to have_css "li", count: 1
    expect(page).to have_content "I am user related"
    expect(page).not_to have_content "I am machine related"
  end

  it "displays user related content when machine learning related content is disabled" do
    Setting["machine_learning.related_content"] = false

    render_inline component

    expect(page).to have_css "li", count: 1
    expect(page).to have_content "I am user related"
    expect(page).not_to have_content "I am machine related"
  end
end
