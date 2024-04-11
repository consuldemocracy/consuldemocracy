require "rails_helper"

describe Comments::AvatarComponent do
  it "displays a regular avatar for regular comments" do
    comment = create(:comment, user: create(:user, username: "Oscar Wilde"))

    render_inline Comments::AvatarComponent.new(comment)

    expect(page).to have_avatar "O"
    expect(page).not_to have_css "img"
  end

  it "displays the admin avatar with an empty alt attribute for admin comments" do
    admin = create(:administrator)
    comment = create(:comment, user: admin.user, administrator_id: admin.id)

    render_inline Comments::AvatarComponent.new(comment)

    expect(page).to have_css "img.admin-avatar[alt='']"
  end

  it "displays the moderator avatar with an empty alt attribute for moderator comments" do
    moderator = create(:moderator)
    comment = create(:comment, user: moderator.user, moderator_id: moderator.id)

    render_inline Comments::AvatarComponent.new(comment)

    expect(page).to have_css "img.moderator-avatar[alt='']"
  end

  it "displays the organization avatar with an empty alt attribute for organization comments" do
    comment = create(:comment, user: create(:organization).user)

    render_inline Comments::AvatarComponent.new(comment)

    expect(page).to have_css "img.avatar[alt='']"
  end

  it "displays an empty icon for comments by hidden users" do
    comment = create(:comment, user: create(:user, :hidden))

    render_inline Comments::AvatarComponent.new(comment)

    expect(page).to have_css ".user-deleted"
    expect(page).not_to have_css "img"
  end

  it "displays an empty icon for comments by erased users" do
    comment = create(:comment, user: create(:user, erased_at: Time.current))

    render_inline Comments::AvatarComponent.new(comment)

    expect(page).to have_css ".user-deleted"
    expect(page).not_to have_css "img"
  end
end
