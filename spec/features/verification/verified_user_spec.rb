require 'rails_helper'

feature 'Verified users' do

  scenario "Verified emails" do
    user = create(:user,
                  residence_verified_at: Time.now,
                  document_number:       '12345678Z',
                  document_type:         '2')

    create(:verified_user,
           document_number: '12345678Z',
           document_type:   '2',
           email:           'rock@example.com')

    create(:verified_user,
            document_number: '12345678Z',
            document_type:   '2',
            email:           'roll@example.com')

    create(:verified_user,
            document_number: '99999999R',
            document_type:   '2',
            email:           'another@example.com')

    login_as(user)
    visit verified_user_path

    expect(page).to have_content 'rock@example.com'
    expect(page).to have_content 'roll@example.com'
  end

  scenario "Verified phones" do
    user = create(:user,
                  residence_verified_at: Time.now,
                  document_number:       '12345678Z',
                  document_type:         '2')

    create(:verified_user,
           document_number: '12345678Z',
           document_type:   '2',
           phone:           '611111111')

    create(:verified_user,
            document_number: '12345678Z',
            document_type:   '2',
            email:           '622222222')

    create(:verified_user,
            document_number: '99999999R',
            document_type:   '2',
            email:           '633333333')

    login_as(user)
    visit verified_user_path

    expect(page).to have_content '611111111'
    expect(page).to have_content '622222222'
  end

  scenario "Select a verified email" do
    user = create(:user,
              residence_verified_at: Time.now,
              document_number:       '12345678Z',
              document_type:         '2')

    verified_user = create(:verified_user,
                           document_number: '12345678Z',
                           document_type:   '2',
                           email:           'rock@example.com')

    login_as(user)
    visit verified_user_path

    within("#verified_user_#{verified_user.id}_email") do
     click_button "Send"
    end

    expect(page).to have_content 'We have send you a confirmation email to your email account: rock@example.com'
    expect(URI.parse(current_url).path).to eq(account_path)
  end

  scenario "Select a verified phone" do
    user = create(:user,
                  residence_verified_at: Time.now,
                  document_number:       '12345678Z',
                  document_type:         '2')

    verified_user = create(:verified_user,
                           document_number: '12345678Z',
                           document_type:   '2',
                           phone:           '611111111')

    login_as(user)
    visit verified_user_path

    within("#verified_user_#{verified_user.id}_phone") do
      click_button "Send"
    end

    expect(page).to have_content 'Enter the confirmation code'
  end

  scenario "Continue without selecting any verified information" do
    user = create(:user,
                  residence_verified_at: Time.now,
                  document_number:       '12345678Z',
                  document_type:         '2')

    create(:verified_user,
           document_number: '12345678Z',
           document_type:   '2',
           phone:           '611111111')

    login_as(user)
    visit verified_user_path

    click_link "Use another phone"

    expect(URI.parse(current_url).path).to eq(new_sms_path)
  end

  scenario "No verified information" do
    user = create(:user, residence_verified_at: Time.now)

    login_as(user)
    visit verified_user_path

    expect(URI.parse(current_url).path).to eq(new_sms_path)
  end

end