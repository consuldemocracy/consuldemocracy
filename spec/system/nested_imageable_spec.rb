require "rails_helper"

describe "Nested imageable" do
  factories = [
    :budget,
    :budget_investment,
    :future_poll_question_option,
    :proposal
  ]

  let(:factory) { factories.sample }
  let!(:imageable) { create(factory) }
  let!(:user) { create(:user, :level_two) }
  let(:path) { attachable_path_for(factory, imageable) }
  let(:submit_button_text) { submit_button_text_for(factory, path) }
  let(:notice_text) { notice_text_for(factory, path) }

  context "New and edit path" do
    before do
      create(:administrator, user: user) if admin_section?(path)
      imageable.update!(author: user) if edit_path?(path)
      do_login_for(user, management: management_section?(path))
      visit path
    end

    scenario "Handles image link visibility, upload, and file updates correctly" do
      expect(page).to have_css "#new_image_link"

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      expect(page).not_to have_css "#new_image_link"
      expect(page).to have_css ".file-name", text: "clippy.jpg"
      within ".image-fields" do
        expect(find("input[name$='[title]']").value).to eq "clippy.jpg"
      end
    end

    scenario "Should not update image file title after choosing a file when a title is already defined" do
      click_link "Add image"

      within ".image-fields" do
        fill_in "Title", with: "Title"
        attach_file "Choose image", file_fixture("clippy.jpg")

        expect(page).to have_css "progress.complete"
        expect(page).to have_field "Title", with: "Title"
      end
    end

    scenario "Should update image cached_attachment field after valid file upload" do
      click_link "Add image"

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
      expect(cached_attachment_field.value).to be_empty

      attach_file "Choose image", file_fixture("clippy.jpg")

      expect(page).to have_css "progress.complete"
      expect(cached_attachment_field.value).not_to be_empty
    end

    scenario "Should not update image cached_attachment field after invalid file upload" do
      imageable_attach_new_file(file_fixture("logo_header.png"), success: false)

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)

      expect(cached_attachment_field.value).to be_empty

      click_button submit_button_text

      within "#nested-image .image-attachment" do
        expect(page).to have_content "can't be blank"
      end
    end

    scenario "Shows image errors after invalid submit and restores add link on cancel" do
      click_link "Add image"
      click_button submit_button_text

      within "#nested-image .image-fields" do
        expect(page).to have_content("can't be blank", count: 2)
        click_link "Cancel"
      end

      expect(page).not_to have_content "Choose image"
      expect(page).to have_link "Add image"
    end

    scenario "Render image preview after sending the form with validation errors" do
      imageable_attach_new_file(file_fixture("clippy.jpg"))
      within_fieldset("Descriptive image") { fill_in "Title", with: "" }

      click_button submit_button_text

      expect(page).to have_content "can't be blank"
      expect(page).to have_css "img[src$='clippy.jpg']"
    end

    scenario "Should remove image after valid file upload and click on remove button" do
      imageable_attach_new_file(file_fixture("clippy.jpg"))

      within "#nested-image .image-fields" do
        click_link "Remove image"
      end

      expect(page).not_to have_css "#nested-image .image-fields"
    end

    context "Budgets, investments and proposals" do
      let(:factory) { (factories - [:future_poll_question_option]).sample }

      scenario "Should show successful notice when resource filled correctly without any nested images" do
        fill_in_required_fields(factory, path)

        click_button submit_button_text

        expect(page).to have_content notice_text
      end
    end

    scenario "Should show successful notice when resource filled correctly and after valid file uploads" do
      fill_in_required_fields(factory, path)

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      click_button submit_button_text

      expect(page).to have_content notice_text
    end

    scenario "Should show new image after successful creation with one uploaded file" do
      fill_in_required_fields(factory, path)

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      click_button submit_button_text

      expect(page).to have_content notice_text

      if factory == :budget
        click_link "Go back to edit budget"
      else
        expect(page).to have_css "figure figcaption"
      end
      expect(page).to have_css "figure img"
    end

    context "when image suggestions are enabled" do
      let(:factory) { :budget_investment }
      let(:path) { new_budget_investment_path(budget_id: imageable.budget_id) }

      before do
        Setting["llm.provider"] = "OpenAI"
        Setting["llm.model"] = "gpt-4o"
        Setting["llm.use_ai_image_suggestions"] = true

        visit path
        click_link "Add image"
      end

      scenario "keeps image suggestions after a failed upload" do
        expect(page).to have_button "Suggest an image with AI"

        attach_file "Choose image", file_fixture("logo_header.png")

        within "#nested-image .image-fields" do
          expect(page).to have_css "progress.errors"
          expect(page).to have_button "Suggest an image with AI"
        end
      end
    end

    scenario "Different URLs for different images" do
      imageable_attach_new_file(file_fixture("clippy.jpg"))

      original_src = find(:fieldset, "Descriptive image").find("img")[:src]

      click_link "Remove image"
      imageable_attach_new_file(file_fixture("custom_map.jpg"))

      updated_src = find(:fieldset, "Descriptive image").find("img")[:src]

      expect(updated_src).not_to eq original_src
    end
  end

  context "Only for edit path" do
    let(:proposal) { create(:proposal, :with_image, author: user) }

    scenario "handles image fields correctly" do
      login_as(user)
      visit edit_proposal_path(proposal)

      expect(page).to have_css ".image-fields", count: 1
      expect(page).not_to have_css "a#new_image_link"

      click_link "Remove image"

      expect(page).not_to have_css ".image-fields"
      expect(page).to have_link id: "new_image_link"

      click_link "Add image"

      expect(page).to have_css ".image-fields", count: 1, visible: :all
    end
  end

  context "Show path" do
    let(:factory) { :budget_investment }
    let(:path) { polymorphic_path(imageable) }
    let!(:image) { create(:image, imageable: imageable) }

    scenario "Show descriptive image and image title when an image exists" do
      visit path

      expect(page).to have_css("img[alt='#{image.title}'][title='#{image.title}']")
      expect(page).to have_content image.title
    end
  end
end
