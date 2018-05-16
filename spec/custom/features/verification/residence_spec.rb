require 'rails_helper'

feature 'Residence' do

  background { create(:geozone) }

  scenario 'Verify resident' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select_date "31-December-#{valid_date_of_birth_year}", from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    expect(page).to have_content 'Residence verified'
  end

  xscenario 'When trying to verify a deregistered account old votes are reassigned' do
    erased_user = create(:user, document_number: '12345678Z', document_type: '1', erased_at: Time.current)
    vote = create(:vote, voter: erased_user)
    new_user = create(:user)

    login_as(new_user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: '12345678Z'
    select 'DNI', from: 'residence_document_type'
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    expect(page).to have_content 'Residence verified'

    expect(vote.reload.voter).to eq(new_user)
    expect(erased_user.reload.document_number).to be_blank
    expect(new_user.reload.document_number).to eq('12345678Z')
  end

end
