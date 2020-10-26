shared_examples "flaggable" do |factory_name, admin: false|
  include ActionView::RecordIdentifier

  let(:flaggable) { create(factory_name) }

  let(:user) do
    if admin
      create(:administrator).user
    else
      create(:user, :level_two)
    end
  end

  let(:path) do
    if flaggable.is_a?(Comment)
      polymorphic_path(flaggable.commentable)
    elsif admin
      admin_polymorphic_path(flaggable)
    else
      polymorphic_path(flaggable)
    end
  end

  scenario "Flagging as inappropriate", :js do
    login_as(user)
    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      find(".icon-flag").click
      click_link "Flag as inappropriate"

      expect(page).to have_css ".flag-active"
      expect(page).to have_link "Unflag", visible: :hidden
      expect(page).not_to have_link "Flag as inappropriate", visible: :all
    end

    expect(Flag.flagged?(user, flaggable)).to be
  end

  scenario "Unflagging", :js do
    Flag.flag(user, flaggable)

    login_as(user)
    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      expect(page).to have_css ".flag-active"

      find(".icon-flag").click
      click_link "Unflag"

      expect(page).not_to have_css ".flag-active"
      expect(page).to have_link "Flag as inappropriate", visible: :hidden
      expect(page).not_to have_link "Unflag", visible: :all
    end

    expect(Flag.flagged?(user, flaggable)).not_to be
  end

  scenario "Flagging and unflagging", :js do
    login_as(user)
    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      find(".icon-flag").click
      click_link "Flag as inappropriate"

      expect(page).to have_css ".flag-active"
      expect(Flag.flagged?(user, flaggable)).to be

      find(".icon-flag").click
      click_link "Unflag"

      expect(page).not_to have_css ".flag-active"
    end

    expect(Flag.flagged?(user, flaggable)).not_to be
  end

  scenario "Flagging a comment with a child does not update its children", :js do
    skip "Only for comments" unless flaggable.is_a?(Comment)

    child_comment = create(:comment, commentable: flaggable.commentable, parent: flaggable)

    login_as(user)
    visit path

    within "##{dom_id(flaggable)} > .comment-body .flag-content" do
      find(".icon-flag").click
      click_link "Flag as inappropriate"

      expect(page).to have_css ".flag-active"
    end

    within "##{dom_id(child_comment)} .flag-content" do
      expect(page).not_to have_css ".flag-active"
    end
  end
end
