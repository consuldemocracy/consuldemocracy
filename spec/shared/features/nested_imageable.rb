shared_examples "nested imageable" do |imageable_factory_name, path, imageable_path_arguments, fill_resource_method_name, submit_button, imageable_success_notice|
  include ActionView::Helpers
  include ImagesHelper
  include ImageablesHelper

  let!(:administrator)       { create(:user) }
  let!(:user)                { create(:user, :level_two) }
  let!(:arguments)           { {} }
  let!(:imageable)           { create(imageable_factory_name, author: user) }

  before do
    create(:administrator, user: administrator)

    if imageable_path_arguments
      imageable_path_arguments.each do |argument_name, path_to_value|
        arguments.merge!("#{argument_name}": imageable.send(path_to_value))
      end
    end
  end

  describe "at #{path}" do

    scenario "Should show new image link when imageable has not an associated image defined" do
      login_as user
      visit send(path, arguments)

      expect(page).to have_selector "#new_image_link", visible: true
    end

    scenario "Should update nested image file name after choosing a file", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/empty.pdf")

      expect(page).to have_selector ".file-name", text: "empty.pdf"
    end

    scenario "Should update nested image file title with file name after choosing a file when no title defined", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/clippy.jpg")

      expect(find("##{imageable_factory_name}_image_attributes_title").value).to eq "clippy.jpg"
    end

    scenario "Should not update nested image file title with file name after choosing a file when title already defined", :js do
      login_as user
      visit send(path, arguments)

      click_link "Add image"
      sleep 1
      fill_in "#{imageable_factory_name}[image_attributes]title", with: "Title"
      attach_file("#{imageable_factory_name}[image_attributes]attachment", "spec/fixtures/files/empty.pdf", make_visible: true)
      sleep 1

      expect(find("##{imageable_factory_name}_image_attributes_title").value).to eq "Title"
    end

    scenario "Should update loading bar style after valid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/clippy.jpg")

      expect(page).to have_selector ".loading-bar.complete"
    end

    scenario "Should update loading bar style after unvalid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/logo_header.png")

      expect(page).to have_selector ".loading-bar.errors"
    end

    scenario "Should update image cached_attachment field after valid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/clippy.jpg")

      expect(find("input[name='#{imageable_factory_name}[image_attributes]cached_attachment']", visible: false).value).to include("clippy.jpg")
    end

    scenario "Should not update image cached_attachment field after unvalid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/logo_header.png")

      expect(find("input[name='#{imageable_factory_name}[image_attributes]cached_attachment']", visible: false).value).to eq ""
    end

    scenario "Should show image errors after unvalid file upload", :js do
      login_as user
      visit send(path, arguments)

      click_link "Add image"
      sleep 1
      click_on submit_button

      within "#nested_image" do
        expect(page).to have_content("can't be blank", count: 2)
      end
    end

    scenario "Should delete image after valid file upload and click on remove button", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/clippy.jpg")
      within "#nested_image" do
        click_link "Remove image"
      end

      expect(page).not_to have_selector("#nested_image")
    end

    scenario "Should delete image after valid file upload and click on remove button", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/clippy.jpg")
      within "#nested_image" do
        click_link "Remove image"
      end

      expect(page).to have_content "Image was deleted successfully."
    end

    scenario "Should show successful notice when resource filled correctly without any nested images", :js do
      login_as user
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      click_on submit_button
      expect(page).to have_content imageable_success_notice
    end

    scenario "Should show successful notice when resource filled correctly and after valid file uploads", :js do
      login_as user
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/clippy.jpg")

      click_on submit_button
      expect(page).to have_content imageable_success_notice
    end

    scenario "Should show new image after successful creation with one uploaded file", :js do
      login_as user
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      imageable_attach_new_file(imageable_factory_name, 0, "spec/fixtures/files/clippy.jpg")

      click_on submit_button
      imageable_redirected_to_resource_show_or_navigate_to

      expect(page).to have_selector "figure .image"
      expect(page).to have_selector "figure figcaption"
    end


  end

end

def imageable_redirected_to_resource_show_or_navigate_to
  find("a", text: "Not now, go to my proposal")
  click_on "Not now, go to my proposal"
rescue
  return
end

def imageable_attach_new_file(imageable_factory_name, index, path)
  click_link "Add image"
  sleep 1
  attach_file("#{imageable_factory_name}[image_attributes]attachment", path, make_visible: true)
  sleep 1
end

def imageable_fill_new_valid_proposal
  fill_in :proposal_title, with: "Proposal title"
  fill_in :proposal_summary, with: "Proposal summary"
  fill_in :proposal_question, with: "Proposal question?"
  check :proposal_terms_of_service
end

def imageable_fill_new_valid_budget_investment
  page.select imageable.heading.name_scoped_by_group, from: :budget_investment_heading_id
  fill_in :budget_investment_title, with: "Budget investment title"
  fill_in_ckeditor "budget_investment_description", with: "Budget investment description"
  check :budget_investment_terms_of_service
end