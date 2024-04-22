require "rails_helper"

describe Polls::AccessStatusComponent do
  it "asks anonymous users to sign in" do
    render_inline Polls::AccessStatusComponent.new(create(:poll))

    expect(page).to have_css ".not-logged-in", count: 1
    expect(page).to have_content "You must sign in or sign up to participate"
  end

  it "asks unverified users to verify their account" do
    sign_in(create(:user))

    render_inline Polls::AccessStatusComponent.new(create(:poll))

    expect(page).to have_css ".unverified", count: 1
    expect(page).to have_content "You must verify your account to participate"
  end

  it "tell users from different geozones that the poll isn't available" do
    sign_in(create(:user, :level_two))

    render_inline Polls::AccessStatusComponent.new(create(:poll, geozone_restricted: true))

    expect(page).to have_css ".cant-answer", count: 1
    expect(page).to have_content "This poll is not available on your geozone"
  end

  it "informs users when they've already participated" do
    user = create(:user, :level_two)
    poll = create(:poll)
    create(:poll_voter, user: user, poll: poll)

    sign_in(user)
    render_inline Polls::AccessStatusComponent.new(poll)

    expect(page).to have_css ".already-answer", count: 1
    expect(page).to have_content "You already have participated in this poll"
  end

  it "is not rendered when users can vote" do
    sign_in(create(:user, :level_two))

    render_inline Polls::AccessStatusComponent.new(create(:poll))

    expect(page).not_to be_rendered
  end
end
