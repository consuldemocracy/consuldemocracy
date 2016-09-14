require 'rails_helper'

feature 'Admin enquiries' do
  background { login_as(create(:administrator).user) }

  scenario 'Index' do
    e1 = create(:enquiry)
    e2 = create(:enquiry)

    visit admin_enquiries_path

    expect(page).to have_content(e1.title)
    expect(page).to have_content(e2.title)
  end

  scenario 'Destroy' do
    e1 = create(:enquiry)
    e2 = create(:enquiry)

    visit admin_enquiries_path

    within("#enquiry_#{e1.id}") do
      click_link "Delete"
    end

    expect(page).to_not have_content(e1.title)
    expect(page).to have_content(e2.title)
  end
end
