shared_examples "nested imageable" do |imageable_factory_name, path, imageable_path_arguments,
                                       fill_resource_method_name, submit_button, imageable_success_notice,
                                       has_many_images = false, management: false|
  let!(:user)                { create(:user, :level_two) }
  let!(:arguments)           { {} }
  let!(:imageable)           { create(imageable_factory_name) }
  let(:management)           { management }

  before do
    create(:administrator, user: user)

    imageable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": imageable.send(path_to_value))
    end

    imageable.update(author: user) if imageable.respond_to?(:author)
  end

  describe "at #{path}" do
    scenario "Should show new image link when imageable has not an associated image defined" do
      do_login_for user, management: management
      visit send(path, arguments)

      expect(page).to have_selector "#new_image_link"
    end

    scenario "Should hide new image link after adding one image" do
      do_login_for user, management: management
      visit send(path, arguments)

      click_on "Add image"

      expect(page).not_to have_selector "#new_image_link"
    end

    scenario "Should update nested image file name after choosing any file" do
      do_login_for user, management: management
      visit send(path, arguments)

      click_link "Add image"
      attach_file "Choose image", file_fixture("clippy.jpg")

      expect(page).to have_selector ".file-name", text: "clippy.jpg"
    end

    scenario "Should update nested image file title with file name after choosing a file when no title defined" do
      do_login_for user, management: management
      visit send(path, arguments)

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      expect_image_has_title("clippy.jpg")
    end

    scenario "Should not update nested image file title with file name after choosing a file when title already defined" do
      do_login_for user, management: management
      visit send(path, arguments)

      click_link "Add image"
      input_title = find(".image input[name$='[title]']")
      fill_in input_title[:id], with: "Title"
      attach_file "Choose image", file_fixture("clippy.jpg")

      if has_many_images
        expect(find("input[id$='_title']").value).to eq "Title"
      else
        expect(find("##{imageable_factory_name}_image_attributes_title").value).to eq "Title"
      end
    end

    scenario "Should update loading bar style after valid file upload" do
      do_login_for user, management: management
      visit send(path, arguments)

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      expect(page).to have_selector ".loading-bar.complete"
    end

    scenario "Should update loading bar style after invalid file upload" do
      do_login_for user, management: management
      visit send(path, arguments)

      imageable_attach_new_file(file_fixture("logo_header.png"), false)

      expect(page).to have_selector ".loading-bar.errors"
    end

    scenario "Should update image cached_attachment field after valid file upload" do
      do_login_for user, management: management
      visit send(path, arguments)

      click_link "Add image"

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
      expect(cached_attachment_field.value).to be_empty

      attach_file "Choose image", file_fixture("clippy.jpg")

      expect(page).to have_css(".loading-bar.complete")
      expect(cached_attachment_field.value).not_to be_empty
    end

    scenario "Should not update image cached_attachment field after invalid file upload" do
      do_login_for user, management: management
      visit send(path, arguments)

      imageable_attach_new_file(file_fixture("logo_header.png"), false)

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)

      expect(cached_attachment_field.value).to be_empty
    end

    scenario "Should show nested image errors after invalid form submit" do
      do_login_for user, management: management
      visit send(path, arguments)

      click_link "Add image"
      click_on submit_button

      within "#nested-image .image" do
        expect(page).to have_content("can't be blank", count: 2)
      end
    end

    scenario "Render image preview after sending the form with validation errors",
             unless: imageable_factory_name == "poll_question_answer" do
      do_login_for user, management: management
      visit send(path, arguments)

      imageable_attach_new_file(file_fixture("clippy.jpg"))
      within_fieldset("Descriptive image") { fill_in "Title", with: "" }
      click_on submit_button

      expect(page).to have_content "can't be blank"
      expect(page).to have_css "img[src$='clippy.jpg']"
    end

    scenario "Should remove nested image after valid file upload and click on remove button" do
      do_login_for user, management: management
      visit send(path, arguments)

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      within "#nested-image .image" do
        click_link "Remove image"
      end

      expect(page).not_to have_selector("#nested-image .image")
    end

    scenario "Should show successful notice when resource filled correctly without any nested images",
             unless: has_many_images do
      do_login_for user, management: management
      visit send(path, arguments)

      send(fill_resource_method_name) if fill_resource_method_name
      click_on submit_button
      expect(page).to have_content imageable_success_notice
    end

    scenario "Should show successful notice when resource filled correctly and after valid file uploads" do
      do_login_for user, management: management
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      expect(page).to have_selector ".loading-bar.complete"

      click_on submit_button

      expect(page).to have_content imageable_success_notice
    end

    scenario "Should show new image after successful creation with one uploaded file" do
      do_login_for user, management: management
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      expect(page).to have_selector ".loading-bar.complete"

      click_on submit_button

      expect(page).to have_content imageable_success_notice

      imageable_redirected_to_resource_show_or_navigate_to(imageable)

      expect(page).to have_selector "figure img"
      expect(page).to have_selector "figure figcaption" if show_caption_for?(imageable_factory_name)
    end

    scenario "Different URLs for different images" do
      do_login_for user, management: management
      visit send(path, arguments)

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      original_src = find(:fieldset, "Descriptive image").find("img")[:src]

      click_link "Remove image"
      imageable_attach_new_file(file_fixture("custom_map.jpg"))

      updated_src = find(:fieldset, "Descriptive image").find("img")[:src]

      expect(updated_src).not_to eq original_src
    end

    if path.include? "edit"
      scenario "show persisted image" do
        create(:image, imageable: imageable)
        do_login_for user, management: management

        visit send(path, arguments)

        expect(page).to have_css ".image", count: 1
        expect(page).not_to have_css "a#new_image_link"
      end

      scenario "remove nested field after removing the image" do
        create(:image, imageable: imageable)
        do_login_for user, management: management

        visit send(path, arguments)
        click_link "Remove image"

        expect(page).not_to have_css ".image"
        expect(page).to have_css "a#new_image_link"
      end

      scenario "don't duplicate fields after removing and adding an image" do
        create(:image, imageable: imageable)
        do_login_for user, management: management

        visit send(path, arguments)
        click_link "Remove image"
        click_link "Add image"

        expect(page).to have_css ".image", count: 1, visible: :all
      end
    end
  end
end
