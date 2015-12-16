require 'rails_helper'

feature 'Legislation' do

  scenario 'Show' do
    legislation = create(:legislation, title: 'Change the world', body: 'To achieve this...')

    visit legislation_path(legislation)

    expect(page).to have_content 'Change the world'
    expect(page).to have_content 'To achieve this...'
  end

  context 'Annotations', :js do

    background { login_as(create :user) }

    scenario 'Create' do
      legislation = create(:legislation, body: "In order to achieve...")

      visit legislation_path(legislation)

      page.find(:css, "#test").double_click
      page.find(:css, ".annotator-adder button").click

      fill_in 'annotator-field-0', with: 'this is my annotation'
      page.find(:css, ".annotator-controls a[href='#save']").click

      within ".annotate" do
        expect(page).to have_css ".annotator-hl[data-annotation-id]"
      end

      visit legislation_path(legislation)

      within ".annotate" do
        expect(page).to have_css ".annotator-hl[data-annotation-id]"
      end
    end

    scenario 'Update' do
      legislation = create(:legislation, body: "In order to achieve...")
      annotation = create(:annotation, legislation: legislation, text: "this one" , quote: "In order to achieve...", ranges: [{"start"=>"/div[2]", "startOffset"=>12, "end"=>"/div[2]", "endOffset"=>19}])

      visit legislation_path(legislation)

      page.find(:css, ".annotator-hl").click
      page.find(:css, ".annotator-edit").click

      fill_in 'annotator-field-0', with: 'editing my annotation'
      page.find(:css, ".annotator-controls a[href='#save']").click

      page.find(:css, ".annotator-hl").click
      expect(page).to have_css ".annotator-item", text: 'editing my annotation'

      visit legislation_path(legislation)

      page.find(:css, ".annotator-hl").click
      expect(page).to have_css ".annotator-item", text: 'editing my annotation'
    end

    scenario 'Destroy' do
      legislation = create(:legislation, body: "In order to achieve...")
      annotation = create(:annotation, legislation: legislation, text: "this one" , quote: "achieve", ranges: [{"start"=>"/div[2]", "startOffset"=>12, "end"=>"/div[2]", "endOffset"=>19}])

      visit legislation_path(legislation)

      expect(page).to have_css ".annotator-hl[data-annotation-id='#{annotation.id}']"

      page.find(:css, ".annotator-hl").click
      page.find(:css, ".annotator-delete").click

      expect(page).to_not have_css ".annotator-hl[data-annotation-id='#{annotation.id}']"
    end

    scenario 'Search' do
      legislation = create(:legislation, body: "In order to achieve...")
      annotation1 = create(:annotation, legislation: legislation, text: "this one" , quote: "achieve", ranges: [{"start"=>"/div[2]", "startOffset"=>12, "end"=>"/div[2]", "endOffset"=>19}])
      annotation2 = create(:annotation, legislation: legislation, text: "this one" , quote: "achieve", ranges: [{"start"=>"/div[2]", "startOffset"=>5, "end"=>"/div[2]", "endOffset"=>10}])

      visit legislation_path(legislation)

      within ".annotate" do
        expect(page).to have_css ".annotator-hl[data-annotation-id='#{annotation1.id}']"
        expect(page).to have_css ".annotator-hl[data-annotation-id='#{annotation2.id}']"
      end
    end

  end

end

## Notes logged in and not logged in users
