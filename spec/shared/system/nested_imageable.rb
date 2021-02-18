shared_examples "nested imageable" do |imageable_factory_name, path, imageable_path_arguments, fill_resource_method_name, submit_button, imageable_success_notice, has_many_images = false|
  let!(:user)                { create(:user, :level_two) }
  let!(:arguments)           { {} }
  let!(:imageable)           { create(imageable_factory_name) }

  before do
    create(:administrator, user: user)

    imageable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": imageable.send(path_to_value))
    end

    imageable.update(author: user) if imageable.respond_to?(:author)
  end

  describe "at #{path}" do
    scenario "Should show new image link when imageable has not an associated image defined" do
      login_as user
      visit send(path, arguments)

      expect(page).to have_selector "#new_image_link"
    end

    scenario "Should hide new image link after adding one image", :js do
      login_as user
      visit send(path, arguments)

      click_on "Add image"

      expect(page).not_to have_selector "#new_image_link"
    end

    scenario "Should update nested image file name after choosing any file", :js do
      login_as user
      visit send(path, arguments)

      click_link "Add image"
      image_input = find(".image").find("input[type=file]", visible: :hidden)
      attach_file(
        image_input[:id],
        Rails.root.join("spec/fixtures/files/clippy.jpg"),
        make_visible: true
      )

      expect(page).to have_selector ".file-name", text: "clippy.jpg"
    end

    scenario "Should update nested image file title with file name after choosing a file when no title defined", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/clippy.jpg")
      )

      expect_image_has_title("clippy.jpg")
    end

    scenario "Should not update nested image file title with file name after choosing a file when title already defined", :js do
      login_as user
      visit send(path, arguments)

      click_link "Add image"
      input_title = find(".image input[name$='[title]']")
      fill_in input_title[:id], with: "Title"
      image_input = find(".image").find("input[type=file]", visible: :hidden)
      attach_file(
        image_input[:id],
        Rails.root.join("spec/fixtures/files/clippy.jpg"),
        make_visible: true
      )

      if has_many_images
        expect(find("input[id$='_title']").value).to eq "Title"
      else
        expect(find("##{imageable_factory_name}_image_attributes_title").value).to eq "Title"
      end
    end

    scenario "Should update loading bar style after valid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/clippy.jpg")
      )

      expect(page).to have_selector ".loading-bar.complete"
    end

    scenario "Should update loading bar style after invalid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/logo_header.png"),
        false
      )

      expect(page).to have_selector ".loading-bar.errors"
    end

    scenario "Should update image cached_attachment field after valid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/clippy.jpg")
      )

      expect_image_has_cached_attachment(".jpg")
    end

    scenario "Should not update image cached_attachment field after invalid file upload", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/logo_header.png"),
        false
      )

      expect_image_has_cached_attachment("")
    end

    scenario "Should show nested image errors after invalid form submit", :js do
      login_as user
      visit send(path, arguments)

      click_link "Add image"
      click_on submit_button

      if has_many_images
        # Pending. Review soon and test
      else
        within "#nested-image .image" do
          expect(page).to have_content("can't be blank", count: 2)
        end
      end
    end

    scenario "Should remove nested image after valid file upload and click on remove button", :js do
      login_as user
      visit send(path, arguments)

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/clippy.jpg")
      )

      within "#nested-image .image" do
        click_link "Remove image"
      end

      expect(page).not_to have_selector("#nested-image .image")
    end

    scenario "Should show successful notice when resource filled correctly without any nested images", :js do
      if has_many_images
        skip "no need to test, there are no attributes for the parent resource"
      else
        login_as user
        visit send(path, arguments)

        send(fill_resource_method_name) if fill_resource_method_name
        click_on submit_button
        expect(page).to have_content imageable_success_notice
      end
    end

    scenario "Should show successful notice when resource filled correctly and after valid file uploads", :js do
      login_as user
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/clippy.jpg")
      )

      expect(page).to have_selector ".loading-bar.complete"

      click_on submit_button

      expect(page).to have_content imageable_success_notice
    end

    scenario "Should show new image after successful creation with one uploaded file", :js do
      login_as user
      visit send(path, arguments)
      send(fill_resource_method_name) if fill_resource_method_name

      imageable_attach_new_file(
        imageable_factory_name,
        Rails.root.join("spec/fixtures/files/clippy.jpg")
      )

      expect(page).to have_selector ".loading-bar.complete"

      click_on submit_button
      imageable_redirected_to_resource_show_or_navigate_to

      if has_many_images
        # Pending. Review soon and test
      else
        expect(page).to have_selector "figure img"
        expect(page).to have_selector "figure figcaption"
      end
    end

    if path.include? "edit"
      scenario "Should show persisted image" do
        create(:image, imageable: imageable)
        login_as user
        visit send(path, arguments)

        expect(page).to have_css ".image", count: 1
      end

      scenario "Should not show add image button when image already exists", :js do
        create(:image, imageable: imageable)
        login_as user
        visit send(path, arguments)

        expect(page).not_to have_css "a#new_image_link"
      end

      scenario "Should remove nested field after remove image", :js do
        create(:image, imageable: imageable)
        login_as user
        visit send(path, arguments)
        click_on "Remove image"

        expect(page).not_to have_css ".image"
      end

      scenario "Should show add image button after remove image", :js do
        create(:image, imageable: imageable)
        login_as user
        visit send(path, arguments)
        click_on "Remove image"

        expect(page).to have_css "a#new_image_link"
      end
    end
  end
end

def imageable_redirected_to_resource_show_or_navigate_to
  find("a", text: "Not now, go to my proposal")
  click_on "Not now, go to my proposal"
rescue
  nil
end

def imageable_attach_new_file(_imageable_factory_name, path, success = true)
  click_link "Add image"
  within "#nested-image" do
    image = find(".image")
    image_input = image.find("input[type=file]", visible: :hidden)
    attach_file(image_input[:id], path, make_visible: true)
    within image do
      if success
        expect(page).to have_css(".loading-bar.complete")
      else
        expect(page).to have_css(".loading-bar.errors")
      end
    end
  end
end

def imageable_fill_new_valid_proposal
  fill_in "Proposal title", with: "Proposal title"
  fill_in "Proposal summary", with: "Proposal summary"
  check :proposal_terms_of_service
end

def imageable_fill_new_valid_budget_investment
  page.select imageable.heading.name_scoped_by_group, from: :budget_investment_heading_id
  fill_in "Title", with: "Budget investment title"
  fill_in_ckeditor "Description", with: "Budget investment description"
  check :budget_investment_terms_of_service
end

def expect_image_has_title(title)
  image = find(".image")

  within image do
    expect(find("input[name$='[title]']").value).to eq title
  end
end

def expect_image_has_cached_attachment(extension)
  within "#nested-image" do
    image = find(".image")

    within image do
      expect(find("input[name$='[cached_attachment]']", visible: :hidden).value).to end_with(extension)
    end
  end
end
