feature 'Signature sheets' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Index"

  scenario 'Create' do
    visit admin_path

    click_link 'Signature Sheets'
    click_link 'New'

    select "Proposal", from: "signable_type"
    fill_in "signable_id", with: "1"
    fill_in "document_numbers", with: "12345678Z, 99999999Z"
    click_button "Save"

    expect(page).to have_content "Signature sheet saved successfully"
  end

  scenario 'Errors on create'

  scenario 'Show' do
    #display signable
    #display created_at
    #display author
    #display valid signatures count
    #display invalid signatures count
    #display invalid signatures with their error
  end

end