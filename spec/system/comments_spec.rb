require "rails_helper"

describe "Comments" do
  let(:factory) {
                    [
                      :budget_investment,
                      :debate,
                      :legislation_annotation,
                      :legislation_question,
                      :poll_with_author,
                      :proposal,
                      :topic_with_community,
                      :topic_with_investment_community
                    ].sample
                  }
  let(:resource) { create(factory) }
  let(:user) do
    if factory == :legislation_question
      create(:user, :level_two)
    else
      create(:user)
    end
  end
  let(:fill_text) do
    if factory == :legislation_question
      "Leave your answer"
    else
      "Leave your comment"
    end
  end
  let(:button_text) do
    if factory == :legislation_question
      "Publish answer"
    else
      "Publish comment"
    end
  end

  describe "Index" do
    context "Budget Investments" do
      let(:investment) { create(:budget_investment) }

      scenario "render comments" do
        not_valuations = 3.times.map { create(:comment, commentable: investment) }
        create(:comment, :valuation, commentable: investment, subject: "Not viable")

        visit budget_investment_path(investment.budget, investment)

        expect(page).to have_css(".comment", count: 3)
        expect(page).not_to have_content("Not viable")

        within("#comments") do
          not_valuations.each do |comment|
            expect(page).to have_content comment.user.name
            expect(page).to have_content I18n.l(comment.created_at, format: :datetime)
            expect(page).to have_content comment.body
          end
        end
      end
    end

    context "Debates, annotations, question, Polls, Proposals and Topics" do
      let(:factory) { (factories - [:budget_investment]).sample }

      scenario "render comments" do
        3.times { create(:comment, commentable: resource) }
        comment = Comment.includes(:user).last

        visit polymorphic_path(resource)

        if factory == :legislation_annotation
          expect(page).to have_css(".comment", count: 4)
        else
          expect(page).to have_css(".comment", count: 3)
        end

        within first(".comment") do
          expect(page).to have_content comment.user.name
          expect(page).to have_content I18n.l(comment.created_at, format: :datetime)
          expect(page).to have_content comment.body
        end
      end
    end
  end

  scenario "Show" do
    parent_comment = create(:comment, commentable: resource, body: "Parent")
    create(:comment, commentable: resource, parent: parent_comment, body: "First subcomment")
    create(:comment, commentable: resource, parent: parent_comment, body: "Last subcomment")

    visit comment_path(parent_comment)

    expect(page).to have_css(".comment", count: 3)
    expect(page).to have_content "Parent"
    expect(page).to have_content "First subcomment"
    expect(page).to have_content "Last subcomment"

    expect(page).to have_link "Go back to #{resource.title}",
                              href: polymorphic_path(resource)

    within ".comment", text: "Parent" do
      expect(page).to have_css ".comment", count: 2
    end
  end

  scenario "Link to comment show" do
    comment = create(:comment, commentable: resource, user: user)

    visit polymorphic_path(resource)

    within "#comment_#{comment.id}" do
      click_link comment.created_at.strftime("%Y-%m-%d %T")
    end

    expect(page).to have_link "Go back to #{resource.title}"
    expect(page).to have_current_path(comment_path(comment))
  end

  scenario "Collapsable comments" do
    if factory == :legislation_annotation
      parent_comment = resource.comments.first
    else
      parent_comment = create(:comment, body: "Main comment", commentable: resource)
    end
    child_comment = create(:comment,
                           body: "First subcomment",
                           commentable: resource,
                           parent: parent_comment)
    grandchild_comment = create(:comment,
                                body: "Last subcomment",
                                commentable: resource,
                                parent: child_comment)

    visit polymorphic_path(resource)

    expect(page).to have_css(".comment", count: 3)
    expect(page).to have_content("1 response (collapse)", count: 2)

    within ".comment .comment", text: "First subcomment" do
      click_link text: "1 response (collapse)"
    end

    expect(page).to have_css(".comment", count: 2)
    expect(page).to have_content("1 response (collapse)")
    expect(page).to have_content("1 response (show)")
    expect(page).not_to have_content grandchild_comment.body

    within ".comment .comment", text: "First subcomment" do
      click_link text: "1 response (show)"
    end

    expect(page).to have_css(".comment", count: 3)
    expect(page).to have_content("1 response (collapse)", count: 2)
    expect(page).to have_content grandchild_comment.body

    within ".comment", text: parent_comment.body do
      click_link text: "1 response (collapse)", match: :first
    end

    expect(page).to have_css(".comment", count: 1)
    expect(page).to have_content("1 response (show)")
    expect(page).not_to have_content child_comment.body
    expect(page).not_to have_content grandchild_comment.body
  end

  describe "Not logged user" do
    scenario "can not see comments forms" do
      create(:comment, commentable: resource)

      visit polymorphic_path(resource)

      expect(page).to have_content "You must sign in or sign up to leave a comment"
      within("#comments") do
        expect(page).not_to have_content fill_text
        expect(page).not_to have_content "Reply"
      end
    end
  end

  scenario "Comment order" do
    c1 = create(:comment, :with_confidence_score, commentable: resource, cached_votes_up: 100,
                                                  cached_votes_total: 120, created_at: Time.current - 2)
    c2 = create(:comment, :with_confidence_score, commentable: resource, cached_votes_up: 10,
                                                  cached_votes_total: 12, created_at: Time.current - 1)
    c3 = create(:comment, :with_confidence_score, commentable: resource, cached_votes_up: 1,
                                                  cached_votes_total: 2, created_at: Time.current)

    visit polymorphic_path(resource, order: :most_voted)

    expect(c1.body).to appear_before(c2.body)
    expect(c2.body).to appear_before(c3.body)

    click_link "Newest first"

    expect(page).to have_link "Newest first", class: "is-active"
    expect(page).to have_current_path(/#comments/, url: true)
    expect(c3.body).to appear_before(c2.body)
    expect(c2.body).to appear_before(c1.body)

    click_link "Oldest first"

    expect(page).to have_link "Oldest first", class: "is-active"
    expect(page).to have_current_path(/#comments/, url: true)
    expect(c1.body).to appear_before(c2.body)
    expect(c2.body).to appear_before(c3.body)
  end

  scenario "Creation date works differently in roots and child comments when sorting by confidence_score" do
    old_root = create(:comment, commentable: resource, created_at: Time.current - 10)
    new_root = create(:comment, commentable: resource, created_at: Time.current)
    old_child = create(:comment,
                       commentable: resource,
                       parent_id: new_root.id,
                       created_at: Time.current - 10)
    new_child = create(:comment, commentable: resource, parent_id: new_root.id, created_at: Time.current)

    visit polymorphic_path(resource, order: :most_voted)

    expect(new_root.body).to appear_before(old_root.body)
    expect(old_child.body).to appear_before(new_child.body)

    visit polymorphic_path(resource, order: :newest)

    expect(new_root.body).to appear_before(old_root.body)
    expect(new_child.body).to appear_before(old_child.body)

    visit polymorphic_path(resource, order: :oldest)

    expect(old_root.body).to appear_before(new_root.body)
    expect(old_child.body).to appear_before(new_child.body)
  end

  scenario "Turns links into html links" do
    create(:comment, commentable: resource, body: "Built with http://rubyonrails.org/")

    visit polymorphic_path(resource)

    within first(".comment") do
      expect(page).to have_content "Built with http://rubyonrails.org/"
      expect(page).to have_link("http://rubyonrails.org/", href: "http://rubyonrails.org/")
      expect(find_link("http://rubyonrails.org/")[:rel]).to eq("nofollow")
      expect(find_link("http://rubyonrails.org/")[:target]).to be_blank
    end
  end

  scenario "Sanitizes comment body for security" do
    create(:comment, commentable: resource,
                     body: "<script>alert('hola')</script> " \
                           "<a href=\"javascript:alert('sorpresa!')\">click me<a/> " \
                           "http://www.url.com")

    visit polymorphic_path(resource)

    within first(".comment") do
      expect(page).to have_content "click me http://www.url.com"
      expect(page).to have_link("http://www.url.com", href: "http://www.url.com")
      expect(page).not_to have_link("click me")
    end
  end

  scenario "Paginated comments" do
    per_page = 10
    (per_page + 2).times { create(:comment, commentable: resource) }

    visit polymorphic_path(resource)

    expect(page).to have_css(".comment", count: per_page)
    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).not_to have_content("3")
      click_link "Next", exact: false
    end

    if factory == :legislation_annotation
      expect(page).to have_css(".comment", count: 3)
    else
      expect(page).to have_css(".comment", count: 2)
    end
    expect(page).to have_current_path(/#comments/, url: true)
  end

  scenario "Create" do
    login_as(user)
    visit polymorphic_path(resource)

    fill_in fill_text, with: "Have you thought about...?"
    click_button button_text

    if [:debate, :legislation_question].include?(factory)
      within "#comments" do
        expect(page).to have_content "(1)"
      end
    elsif factory == :legislation_annotation
      within "#comments" do
        expect(page).to have_content "Comments (2)"
      end
    else
      within "#tab-comments-label" do
        expect(page).to have_content "Comments (1)"
      end
    end

    within "#comments" do
      expect(page).to have_content "Have you thought about...?"
    end
  end

  scenario "Reply" do
    comment = create(:comment, commentable: resource)

    login_as(user)
    visit polymorphic_path(resource)

    within "#comment_#{comment.id}" do
      click_link "Reply"
    end

    within "#js-comment-form-comment_#{comment.id}" do
      fill_in fill_text, with: "It will be done next week."
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "It will be done next week."
    end

    expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
  end

  scenario "Reply update parent comment responses count" do
    comment = create(:comment, commentable: resource)

    login_as(user)
    visit polymorphic_path(resource)

    within ".comment", text: comment.body do
      click_link "Reply"
      fill_in fill_text, with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("1 response (collapse)")
    end
  end

  scenario "Errors on create" do
    login_as(user)
    visit polymorphic_path(resource)

    click_button button_text

    expect(page).to have_content "Can't be blank"
  end
end
