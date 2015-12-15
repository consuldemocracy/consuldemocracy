require 'rails_helper'

feature 'Legislation' do

  scenario 'Show' do
    legislation = create(:legislation, title: 'Change the world', body: 'To achieve this...')

    visit legislation_path(legislation)

    expect(page).to have_content 'Change the world'
    expect(page).to have_content 'To achieve this...'
  end

  context 'Annotations', :js, :focus do

    scenario 'Create' do
      user = create(:user)
      legislation = create(:legislation, title: 'Participatory Democracy', body: "In order to achieve...")

      login_as(user)
      visit legislation_path(legislation)

      page.find(:css, "#test").double_click
      page.find(:css, ".annotator-adder button").click
      fill_in 'annotator-field-0', with: 'this is my annotation'
      page.find(:css, ".annotator-controls a[href='#save']").click

      within ".annotate" do
        expect(page).to have_css ".annotator-hl"
      end

      annotation = Annotation.last
      within ".annotate" do
        expect(page).to have_css ".annotator-hl[data-annotation-id='#{annotation.id}']"
      end

      visit legislation_path(legislation)
      within ".annotate" do
        expect(page).to have_css ".annotator-hl[data-annotation-id='#{annotation.id}']"
      end
    end

    scenario 'Search' do
      user = create(:user)
      legislation = create(:legislation, title: 'Participatory Democracy', body: "In order to achieve...")
      annotation = create(:annotation, legislation: legislation, text: "this one" , quote: "achieve", ranges: [{"start"=>"/div[2]", "startOffset"=>12, "end"=>"/div[2]", "endOffset"=>19}])

      login_as(user)
      visit legislation_path(legislation)

      within ".annotate" do
        expect(page).to have_css ".annotator-hl[data-annotation-id='#{annotation.id}']"
      end
    end

    scenario 'Update'
    scenario 'Destroy'
  end

end

## Notes logged in and not logged in users