require "rails_helper"

describe "Commenting topics from proposals" do
  let(:user)     { create(:user) }
  let(:proposal) { create(:proposal) }

  it_behaves_like "flaggable", :topic_with_community_comment

  scenario "Sanitizes comment body for security" do
    community = proposal.community
    topic = create(:topic, community: community)
    create(:comment, commentable: topic,
                     body: "<script>alert('hola')</script> " \
                           "<a href=\"javascript:alert('sorpresa!')\">click me<a/> " \
                           "http://www.url.com")

    visit community_topic_path(community, topic)

    within first(".comment") do
      expect(page).to have_content "click me http://www.url.com"
      expect(page).to have_link("http://www.url.com", href: "http://www.url.com")
      expect(page).not_to have_link("click me")
    end
  end

  scenario "Paginated comments" do
    community = proposal.community
    topic = create(:topic, community: community)
    per_page = 10
    (per_page + 2).times { create(:comment, commentable: topic) }

    visit community_topic_path(community, topic)

    expect(page).to have_css(".comment", count: per_page)
    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).not_to have_content("3")
      click_link "Next", exact: false
    end

    expect(page).to have_css(".comment", count: 2)
    expect(page).to have_current_path(/#comments/, url: true)
  end

  scenario "Create" do
    community = proposal.community
    topic = create(:topic, community: community)

    login_as(user)
    visit community_topic_path(community, topic)

    fill_in "Leave your comment", with: "Have you thought about...?"
    click_button "Publish comment"

    within "#comments" do
      expect(page).to have_content "Have you thought about...?"
    end

    within "#tab-comments-label" do
      expect(page).to have_content "Comments (1)"
    end
  end

  scenario "Reply" do
    community = proposal.community
    topic = create(:topic, community: community)
    citizen = create(:user, username: "Ana")
    manuela = create(:user, username: "Manuela")
    comment = create(:comment, commentable: topic, user: citizen)

    login_as(manuela)
    visit community_topic_path(community, topic)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "It will be done next week."
    end

    expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
  end

  scenario "Reply update parent comment responses count" do
    community = proposal.community
    topic = create(:topic, community: community)
    comment = create(:comment, commentable: topic)

    login_as(create(:user))
    visit community_topic_path(community, topic)

    within ".comment", text: comment.body do
      click_link "Reply"
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("1 response (collapse)")
    end
  end

  scenario "Reply show parent comments responses when hidden" do
    community = proposal.community
    topic = create(:topic, community: community)
    comment = create(:comment, commentable: topic)
    create(:comment, commentable: topic, parent: comment)

    login_as(create(:user))
    visit community_topic_path(community, topic)

    within ".comment", text: comment.body do
      click_link text: "1 response (collapse)"
      click_link "Reply"
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("It will be done next week.")
    end
  end

  scenario "Errors on reply" do
    community = proposal.community
    topic = create(:topic, community: community)
    comment = create(:comment, commentable: topic, user: user)

    login_as(user)
    visit community_topic_path(community, topic)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      click_button "Publish reply"
      expect(page).to have_content "Can't be blank"
    end
  end

  scenario "N replies" do
    community = proposal.community
    topic = create(:topic, community: community)
    parent = create(:comment, commentable: topic)

    7.times do
      create(:comment, commentable: topic, parent: parent)
      parent = parent.children.first
    end

    visit community_topic_path(community, topic)
    expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")
  end

  scenario "Erasing a comment's author" do
    community = proposal.community
    topic = create(:topic, community: community)
    comment = create(:comment, commentable: topic, body: "this should be visible")
    comment.user.erase

    visit community_topic_path(community, topic)

    within "#comment_#{comment.id}" do
      expect(page).to have_content("User deleted")
      expect(page).to have_content("this should be visible")
    end
  end

  describe "Moderators" do
    scenario "can create comment as a moderator" do
      community = proposal.community
      topic = create(:topic, community: community)
      moderator = create(:moderator)

      login_as(moderator.user)
      visit community_topic_path(community, topic)

      fill_in "Leave your comment", with: "I am moderating!"
      check "comment-as-moderator-topic_#{topic.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end
    end

    scenario "can create reply as a moderator" do
      community = proposal.community
      topic = create(:topic, community: community)
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      moderator = create(:moderator, user: manuela)
      comment = create(:comment, commentable: topic, user: citizen)

      login_as(manuela)
      visit community_topic_path(community, topic)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "I am moderating!"
        check "comment-as-moderator-comment_#{comment.id}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
    end

    scenario "can not comment as an administrator" do
      community = proposal.community
      topic = create(:topic, community: community)
      moderator = create(:moderator)

      login_as(moderator.user)
      visit community_topic_path(community, topic)

      expect(page).not_to have_content "Comment as administrator"
    end
  end

  describe "Administrators" do
    scenario "can create comment as an administrator" do
      community = proposal.community
      topic = create(:topic, community: community)
      admin = create(:administrator)

      login_as(admin.user)
      visit community_topic_path(community, topic)

      fill_in "Leave your comment", with: "I am your Admin!"
      check "comment-as-administrator-topic_#{topic.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am your Admin!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end
    end

    scenario "can create reply as an administrator" do
      community = proposal.community
      topic = create(:topic, community: community)
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      admin   = create(:administrator, user: manuela)
      comment = create(:comment, commentable: topic, user: citizen)

      login_as(manuela)
      visit community_topic_path(community, topic)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "Top of the world!"
        check "comment-as-administrator-comment_#{comment.id}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "Top of the world!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
    end

    scenario "can not comment as a moderator", :admin do
      community = proposal.community
      topic = create(:topic, community: community)

      visit community_topic_path(community, topic)

      expect(page).not_to have_content "Comment as moderator"
    end
  end

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:proposal)   { create(:proposal) }
    let(:topic)      { create(:topic, community: proposal.community) }
    let!(:comment)   { create(:comment, commentable: topic) }

    before do
      login_as(verified)
    end

    scenario "Show" do
      create(:vote, voter: verified, votable: comment, vote_flag: true)
      create(:vote, voter: unverified, votable: comment, vote_flag: false)

      visit community_topic_path(proposal.community, topic)

      within("#comment_#{comment.id}_votes") do
        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "2 votes"
      end
    end

    scenario "Create" do
      visit community_topic_path(proposal.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Update" do
      visit community_topic_path(proposal.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Allow undoing votes" do
      visit community_topic_path(proposal.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end
end

describe "Commenting topics from budget investments" do
  let(:user)       { create(:user) }
  let(:investment) { create(:budget_investment) }

  scenario "Sanitizes comment body for security" do
    community = investment.community
    topic = create(:topic, community: community)
    create(:comment, commentable: topic,
                     body: "<script>alert('hola')</script> " \
                           "<a href=\"javascript:alert('sorpresa!')\">click me<a/> " \
                           "http://www.url.com")

    visit community_topic_path(community, topic)

    within first(".comment") do
      expect(page).to have_content "click me http://www.url.com"
      expect(page).to have_link("http://www.url.com", href: "http://www.url.com")
      expect(page).not_to have_link("click me")
    end
  end

  scenario "Paginated comments" do
    community = investment.community
    topic = create(:topic, community: community)
    per_page = 10
    (per_page + 2).times { create(:comment, commentable: topic) }

    visit community_topic_path(community, topic)

    expect(page).to have_css(".comment", count: per_page)
    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).not_to have_content("3")
      click_link "Next", exact: false
    end

    expect(page).to have_css(".comment", count: 2)
    expect(page).to have_current_path(/#comments/, url: true)
  end

  scenario "Create" do
    community = investment.community
    topic = create(:topic, community: community)

    login_as(user)
    visit community_topic_path(community, topic)

    fill_in "Leave your comment", with: "Have you thought about...?"
    click_button "Publish comment"

    within "#comments" do
      expect(page).to have_content "Have you thought about...?"
    end

    within "#tab-comments-label" do
      expect(page).to have_content "Comments (1)"
    end
  end

  scenario "Reply" do
    community = investment.community
    topic = create(:topic, community: community)
    citizen = create(:user, username: "Ana")
    manuela = create(:user, username: "Manuela")
    comment = create(:comment, commentable: topic, user: citizen)

    login_as(manuela)
    visit community_topic_path(community, topic)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "It will be done next week."
    end

    expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
  end

  scenario "Errors on reply" do
    community = investment.community
    topic = create(:topic, community: community)
    comment = create(:comment, commentable: topic, user: user)

    login_as(user)
    visit community_topic_path(community, topic)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      click_button "Publish reply"
      expect(page).to have_content "Can't be blank"
    end
  end

  scenario "N replies" do
    community = investment.community
    topic = create(:topic, community: community)
    parent = create(:comment, commentable: topic)

    7.times do
      create(:comment, commentable: topic, parent: parent)
      parent = parent.children.first
    end

    visit community_topic_path(community, topic)
    expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")
  end

  scenario "Erasing a comment's author" do
    community = investment.community
    topic = create(:topic, community: community)
    comment = create(:comment, commentable: topic, body: "this should be visible")
    comment.user.erase

    visit community_topic_path(community, topic)

    within "#comment_#{comment.id}" do
      expect(page).to have_content("User deleted")
      expect(page).to have_content("this should be visible")
    end
  end

  describe "Moderators" do
    scenario "can create comment as a moderator" do
      community = investment.community
      topic = create(:topic, community: community)
      moderator = create(:moderator)

      login_as(moderator.user)
      visit community_topic_path(community, topic)

      fill_in "Leave your comment", with: "I am moderating!"
      check "comment-as-moderator-topic_#{topic.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end
    end

    scenario "can create reply as a moderator" do
      community = investment.community
      topic = create(:topic, community: community)
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      moderator = create(:moderator, user: manuela)
      comment = create(:comment, commentable: topic, user: citizen)

      login_as(manuela)
      visit community_topic_path(community, topic)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "I am moderating!"
        check "comment-as-moderator-comment_#{comment.id}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
    end

    scenario "can not comment as an administrator" do
      community = investment.community
      topic = create(:topic, community: community)
      moderator = create(:moderator)

      login_as(moderator.user)
      visit community_topic_path(community, topic)

      expect(page).not_to have_content "Comment as administrator"
    end
  end

  describe "Administrators" do
    scenario "can create comment as an administrator" do
      community = investment.community
      topic = create(:topic, community: community)
      admin = create(:administrator)

      login_as(admin.user)
      visit community_topic_path(community, topic)

      fill_in "Leave your comment", with: "I am your Admin!"
      check "comment-as-administrator-topic_#{topic.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am your Admin!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end
    end

    scenario "can create reply as an administrator" do
      community = investment.community
      topic = create(:topic, community: community)
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      admin   = create(:administrator, user: manuela)
      comment = create(:comment, commentable: topic, user: citizen)

      login_as(manuela)
      visit community_topic_path(community, topic)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "Top of the world!"
        check "comment-as-administrator-comment_#{comment.id}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "Top of the world!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
    end

    scenario "can not comment as a moderator", :admin do
      community = investment.community
      topic = create(:topic, community: community)

      visit community_topic_path(community, topic)

      expect(page).not_to have_content "Comment as moderator"
    end
  end

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:investment) { create(:budget_investment) }
    let(:topic)      { create(:topic, community: investment.community) }
    let!(:comment)   { create(:comment, commentable: topic) }

    before do
      login_as(verified)
    end

    scenario "Show" do
      create(:vote, voter: verified, votable: comment, vote_flag: true)
      create(:vote, voter: unverified, votable: comment, vote_flag: false)

      visit community_topic_path(investment.community, topic)

      within("#comment_#{comment.id}_votes") do
        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "2 votes"
      end
    end

    scenario "Create" do
      visit community_topic_path(investment.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Update" do
      visit community_topic_path(investment.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Allow undoing votes" do
      visit community_topic_path(investment.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end
end
