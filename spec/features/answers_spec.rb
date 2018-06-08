# coding: utf-8
require 'rails_helper'

feature 'Answers' do

  scenario 'create' do
    login_as (create(:user))

    visit new_answer_path

    fill_in "answer_text", with: "This is a test answer"

    click_button "Send answer"

    expect(page).to have_content("Your answer has been sent.")

    expect(Answer.last.text).to eq("This is a test answer")
  end

end

