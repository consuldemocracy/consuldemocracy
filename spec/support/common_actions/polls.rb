module Polls
  def vote_for_poll_via_web(poll, questions_with_options)
    visit poll_path(poll)

    questions_with_options.each do |question, option|
      within_fieldset(question.title) { choose option }
    end

    click_button "Vote"

    expect(page).to have_content "Thank you for voting!"
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
