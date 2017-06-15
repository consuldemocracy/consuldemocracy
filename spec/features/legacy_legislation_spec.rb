require 'rails_helper'

feature 'Legacy Legislation' do

  scenario 'Show' do
    legacy_legislation = create(:legacy_legislation, title: 'Change the world', body: 'To achieve this...')

    visit legacy_legislation_path(legacy_legislation)

    expect(page).to have_content 'Change the world'
    expect(page).to have_content 'To achieve this...'
  end

  context 'Annotations', :js do

    let(:user) { create(:user) }
    background { login_as user }

    scenario 'Create' do
      legacy_legislation = create(:legacy_legislation)

      visit legacy_legislation_path(legacy_legislation)

      page.find(:css, "#legacy_legislation_body").double_click
      page.find(:css, ".annotator-adder button").click
      fill_in 'annotator-field-0', with: 'this is my annotation'
      page.find(:css, ".annotator-controls a[href='#save']").click

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "this is my annotation"

      visit legacy_legislation_path(legacy_legislation)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "this is my annotation"
    end

    scenario 'Update' do
      legacy_legislation = create(:legacy_legislation)
      annotation = create(:annotation, legacy_legislation: legacy_legislation, user: user, text: "my annotation")

      visit legacy_legislation_path(legacy_legislation)

      expect(page).to have_css ".annotator-hl"
      page.find(:css, ".annotator-hl").click
      page.find(:css, ".annotator-edit").click

      fill_in 'annotator-field-0', with: 'edited annotation'
      page.find(:css, ".annotator-controls a[href='#save']").click

      expect(page).to_not have_css('span', text: 'my annotation')

      page.find(:css, ".annotator-hl").click
      expect(page).to have_content "edited annotation"

      visit legacy_legislation_path(legacy_legislation)

      page.find(:css, ".annotator-hl").click
      expect(page).to have_content "edited annotation"
    end

    scenario 'Destroy' do
      legacy_legislation = create(:legacy_legislation)
      annotation = create(:annotation, legacy_legislation: legacy_legislation, user: user)

      visit legacy_legislation_path(legacy_legislation)

      expect(page).to have_css ".annotator-hl"

      page.find(:css, ".annotator-hl").click
      page.find(:css, ".annotator-delete").click

      expect(page).to_not have_css ".annotator-hl"
    end

    scenario 'Search' do
      legacy_legislation = create(:legacy_legislation)
      annotation1 = create(:annotation, legacy_legislation: legacy_legislation, text: "my annotation",       ranges: [{"start"=>"/div[1]", "startOffset"=>5, "end"=>"/div[1]", "endOffset"=>10}])
      annotation2 = create(:annotation, legacy_legislation: legacy_legislation, text: "my other annotation", ranges: [{"start"=>"/div[1]", "startOffset"=>12, "end"=>"/div[1]", "endOffset"=>19}])

      visit legacy_legislation_path(legacy_legislation)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "my annotation"

      all(".annotator-hl")[1].click
      expect(page).to have_content "my other annotation"
    end

  end

end

## Notes logged in and not logged in users
