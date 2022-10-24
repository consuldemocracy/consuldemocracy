require "rails_helper"

describe "Machine learning" do
  let(:user_tag) { create(:tag, name: "user tag") }
  let(:ml_proposal_tag) { create(:tag, name: "machine learning proposal tag") }
  let(:ml_investment_tag) { create(:tag, name: "machine learning investment tag") }
  let(:proposal) { create(:proposal) }
  let(:related_proposal) { create(:proposal) }
  let(:investment) { create(:budget_investment) }
  let(:related_investment) { create(:budget_investment) }

  before do
    Setting["feature.machine_learning"] = true
    Setting["machine_learning.comments_summary"] = true
    Setting["machine_learning.related_content"] = true
    Setting["machine_learning.tags"] = true

    proposal.update!(tag_list: [user_tag])
    proposal.update!(ml_tag_list: [ml_proposal_tag])
    investment.update!(tag_list: [user_tag])
    investment.update!(ml_tag_list: [ml_investment_tag])
  end

  scenario "proposal view" do
    create(:ml_summary_comment, commentable: proposal, body: "Life is wonderful")
    create(:related_content, parent_relationable: proposal,
           child_relationable: related_proposal,
           machine_learning: true)

    visit proposal_path(proposal)

    within "#tags_proposal_#{proposal.id}" do
      expect(page).not_to have_link "user tag"
      expect(page).to have_link "machine learning proposal tag"
      expect(page).not_to have_link "machine learning investment tag"
    end

    within ".related-content" do
      expect(page).to have_content "Related content (1)"
      expect(page).to have_css ".related-content-title"
      expect(page).to have_content related_proposal.title
    end

    within "#comments" do
      expect(page).to have_content "Comments summary"
      expect(page).to have_content "Life is wonderful"
    end
  end

  scenario "investment view" do
    create(:ml_summary_comment, commentable: investment, body: "Build in the main square")
    create(:related_content, parent_relationable: investment,
           child_relationable: related_investment,
           machine_learning: true)

    visit budget_investment_path(investment.budget, investment)

    within "#tags_budget_investment_#{investment.id}" do
      expect(page).not_to have_link "user tag"
      expect(page).not_to have_link "machine learning proposal tag"
      expect(page).to have_link "machine learning investment tag"
    end

    within ".related-content" do
      expect(page).to have_content "Related content (1)"
      expect(page).to have_css ".related-content-title", count: 1
      expect(page).to have_content related_investment.title
    end

    within "#tab-comments" do
      expect(page).to have_content "Comments summary"
      expect(page).to have_content "Build in the main square"
    end
  end
end
