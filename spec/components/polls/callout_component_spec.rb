require "rails_helper"

describe Polls::CalloutComponent do
  it "asks anonymous users to sign in" do
    render_inline Polls::CalloutComponent.new(create(:poll))

    expect(page).to have_content "You must sign in or sign up to participate"
  end

  it "shows a message to level 2 users when a poll has finished" do
    sign_in(create(:user, :level_two))

    render_inline Polls::CalloutComponent.new(create(:poll, :expired))

    expect(page).to have_content "This poll has finished"
  end

  it "asks unverified users to verify their account" do
    sign_in(create(:user, :incomplete_verification))

    render_inline Polls::CalloutComponent.new(create(:poll))

    expect(page).to have_content "You must verify your account in order to answer"
    expect(page).not_to have_content "You have already participated in this poll. " \
                                     "If you vote again it will be overwritten"
  end
end
