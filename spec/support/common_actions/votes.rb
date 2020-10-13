module Votes
  def expect_message_you_need_to_sign_in
    expect(page).to have_content "You must sign in or sign up to continue"
    expect(page).to have_selector(".in-favor", obscured: true)
  end

  def expect_message_you_need_to_sign_in_to_vote_comments
    within(".participation-not-allowed") do
      expect(page).to have_content "You must sign in or sign up to vote"
    end

    expect(page).not_to have_selector(".participation-allowed")
  end

  def expect_message_to_many_anonymous_votes
    expect(page).to have_content "Too many anonymous votes to admit vote"
    expect(page).to have_selector(".in-favor a", obscured: true)
  end

  def expect_message_only_verified_can_vote_proposals
    expect(page).to have_content "Only verified users can vote on proposals"
    expect(page).to have_selector(".in-favor", obscured: true)
  end
end
