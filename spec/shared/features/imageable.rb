shared_examples "imageable" do |imageable_factory_name, imageable_path, imageable_path_arguments|
  include ActionView::Helpers
  include ImagesHelper
  include ImageablesHelper

  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user) }
  let!(:imageable_arguments)    { {} }
  let!(:imageables_arguments)   { {} }
  let!(:imageable)              { create(imageable_factory_name, author: user) }
  let!(:imageable_dom_name)     { imageable_factory_name.parameterize }

  before do
    create(:administrator, user: administrator)

    imageable_path_arguments.each do |argument_name, path_to_value|
      imageable_arguments.merge!("#{argument_name}": imageable.send(path_to_value))
    end
  end

  context "Show" do

    scenario "Show descriptive image when exists", :js do
      image = create(:image, imageable: imageable)

      visit send(imageable_path, imageable_arguments)

      expect(page).to have_css("img[alt='#{image.title}'][title='#{image.title}']")
    end

    scenario "Show image title when image exists" do
      image = create(:image, imageable: imageable)

      visit send(imageable_path, imageable_arguments)

      expect(page).to have_content image.title
    end

  end

  context "Destroy" do

    let!(:image) { create(:image, imageable: imageable, user: imageable.author) }

    scenario "Should show success notice after successfull deletion by an admin" do
      login_as administrator

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      expect(page).to have_content "Image was deleted successfully."
    end

    scenario "Should show success notice after successfull deletion" do
      login_as imageable.author

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      expect(page).to have_content "Image was deleted successfully."
    end

    scenario "Should not show image after successful deletion" do
      login_as imageable.author

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      expect(page).not_to have_selector "figure img"
    end

    scenario "Should redirect to imageable path after successful deletion" do
      login_as imageable.author

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      within "##{dom_id(imageable)}" do
        expect(page).to have_selector "h1", text: imageable.title
      end
    end

  end

end

def attach_image(path, success = true)
  image = find(".image")
  image_input = image.find("input[type=file]", visible: false)
  attach_file image_input[:id], path, make_visible: true
  if success
    expect(page).to have_css ".loading-bar.complete"
  else
    expect(page).to have_css ".loading-bar.errors"
  end
end
