shared_examples "imageable destroy" do |imageable_factory_name,
                                        imageable_path,
                                        imageable_path_arguments|
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

  context "Destroy" do

    before do
      create(:image, imageable: imageable, user: imageable.author)
    end

    scenario "Administrators cannot destroy imageables they have not authored" do
      login_as(administrator)

      visit send(imageable_path, imageable_arguments)
      expect(page).not_to have_link "Remove image"
    end

    scenario "Users cannot destroy imageables they have not authored" do
      login_as(create(:user))

      visit send(imageable_path, imageable_arguments)
      expect(page).not_to have_link "Remove image"
    end

    scenario "Should show success notice after successful deletion" do
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
