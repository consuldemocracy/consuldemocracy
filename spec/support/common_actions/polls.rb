module Polls
  def vote_for_poll_via_web(poll, question, option)
    visit poll_path(poll)

    within("#poll_question_#{question.id}_options") do
      click_button option

      expect(page).to have_button("You have voted #{option}")
      expect(page).not_to have_button("Vote #{option}")
    end
  end

  def vote_for_poll_via_booth
    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content poll.name

    first(:button, "Confirm vote").click
    expect(page).to have_content "Vote introduced!"
  end

  def confirm_phone(code:)
    fill_in "sms_phone", with: "611111111"
    click_button "Send"

    expect(page).to have_content "Enter the confirmation code sent to you by text message"

    fill_in "sms_confirmation_code", with: code
    click_button "Send"

    expect(page).to have_content "Code correct"
  end
end
