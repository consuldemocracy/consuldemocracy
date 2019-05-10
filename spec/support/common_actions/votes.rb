module Votes
  def expect_message_you_need_to_sign_in
    expect(page).to have_content "You must Sign in or Sign up to continue"
    expect(page).to have_selector(".in-favor", visible: false)
  end

  def expect_message_you_need_to_sign_in_to_vote_comments
    expect(page).to have_content "You must Sign in or Sign up to vote"
    expect(page).to have_selector(".participation-allowed", visible: false)
    expect(page).to have_selector(".participation-not-allowed", visible: true)
  end

  def expect_message_to_many_anonymous_votes
    expect(page).to have_content "Too many anonymous votes to admit vote"
    expect(page).to have_selector(".in-favor a", visible: false)
  end

  def expect_message_only_verified_can_vote_proposals
    expect(page).to have_content "Only verified users can vote on proposals"
    expect(page).to have_selector(".in-favor", visible: false)
  end

  def expect_message_voting_not_allowed
    expect(page).to have_content "Voting phase is closed"
    expect(page).not_to have_selector(".in-favor a")
  end
end
