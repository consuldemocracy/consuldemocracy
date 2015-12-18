require 'rails_helper'

feature 'Legislation' do

  scenario 'Show' do
    legislation = create(:legislation, title: 'Change the world', body: 'To achieve this...')

    visit legislation_path(legislation)

    expect(page).to have_content 'Change the world'
    expect(page).to have_content 'To achieve this...'
  end

  context 'Annotations', :js do

    let(:user) { create(:user) }
    background { login_as user }

    scenario 'Create' do
      legislation = create(:legislation)

      visit legislation_path(legislation)

      page.find(:css, "#legislation_body").double_click
      page.find(:css, ".annotator-adder button").click
      fill_in 'annotator-field-0', with: 'this is my annotation'
      page.find(:css, ".annotator-controls a[href='#save']").click

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "this is my annotation"

      visit legislation_path(legislation)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "this is my annotation"
    end

    scenario 'Update' do
      legislation = create(:legislation)
      annotation = create(:annotation, legislation: legislation, user: user, text: "my annotation")

      visit legislation_path(legislation)

      expect(page).to have_css ".annotator-hl"
      page.find(:css, ".annotator-hl").click
      page.find(:css, ".annotator-edit").click

      fill_in 'annotator-field-0', with: 'edited annotation'
      page.find(:css, ".annotator-controls a[href='#save']").click

      expect(page).to_not have_css('span', text: 'my annotation')

      page.find(:css, ".annotator-hl").click
      expect(page).to have_content "edited annotation"

      visit legislation_path(legislation)

      page.find(:css, ".annotator-hl").click
      expect(page).to have_content "edited annotation"
    end

    scenario 'Destroy' do
      legislation = create(:legislation)
      annotation = create(:annotation, legislation: legislation, user: user)

      visit legislation_path(legislation)

      expect(page).to have_css ".annotator-hl"

      page.find(:css, ".annotator-hl").click
      page.find(:css, ".annotator-delete").click

      expect(page).to_not have_css ".annotator-hl"
    end

    scenario 'Search' do
      legislation = create(:legislation)
      annotation1 = create(:annotation, legislation: legislation, text: "my annotation",       ranges: [{"start"=>"/div[1]", "startOffset"=>5, "end"=>"/div[1]", "endOffset"=>10}])
      annotation2 = create(:annotation, legislation: legislation, text: "my other annotation", ranges: [{"start"=>"/div[1]", "startOffset"=>12, "end"=>"/div[1]", "endOffset"=>19}])

      visit legislation_path(legislation)

      expect(page).to have_css ".annotator-hl"
      first(:css, ".annotator-hl").click
      expect(page).to have_content "my annotation"

      all(".annotator-hl")[1].click
      expect(page).to have_content "my other annotation"
    end

  end

end

## Notes logged in and not logged in users
