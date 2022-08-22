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

  scenario "Flagging as inappropriate" do
    login_as(user)
    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      click_button "Flag as inappropriate"
      click_link "Flag as inappropriate"

      expect(page).to have_button "Unflag"
      expect(page).to have_link "Unflag", visible: :hidden
      expect(page).not_to have_link "Flag as inappropriate", visible: :all
    end

    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      expect(page).to have_link "Unflag", visible: :hidden
      expect(page).not_to have_link "Flag as inappropriate", visible: :all
    end
  end

  scenario "Unflagging" do
    Flag.flag(user, flaggable)

    login_as(user)
    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      expect(page).to have_button "Unflag"

      click_button "Unflag"
      click_link "Unflag"

      expect(page).not_to have_button "Unflag"
      expect(page).to have_link "Flag as inappropriate", visible: :hidden
      expect(page).not_to have_link "Unflag", visible: :all
    end

    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      expect(page).to have_link "Flag as inappropriate", visible: :hidden
      expect(page).not_to have_link "Unflag", visible: :all
    end
  end

  scenario "Flagging and unflagging" do
    login_as(user)
    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      click_button "Flag as inappropriate"
      click_link "Flag as inappropriate"

      expect(page).to have_button "Unflag"

      click_button "Unflag"
      click_link "Unflag"

      expect(page).not_to have_button "Unflag"
    end

    visit path

    within "##{dom_id(flaggable)} .flag-content" do
      expect(page).to have_link "Flag as inappropriate", visible: :hidden
      expect(page).not_to have_link "Unflag", visible: :all
    end
  end

  scenario "Flagging a comment with a child does not update its children", if: factory_name =~ /comment/ do
    child_comment = create(:comment, commentable: flaggable.commentable, parent: flaggable)

    login_as(user)
    visit path

    within "##{dom_id(flaggable)} > .comment-body .flag-content" do
      click_button "Flag as inappropriate"
      click_link "Flag as inappropriate"

      expect(page).to have_button "Unflag"
    end

    within "##{dom_id(child_comment)} .flag-content" do
      expect(page).not_to have_button "Unflag"
    end
  end
end
