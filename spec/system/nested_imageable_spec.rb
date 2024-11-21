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
  let(:path) do
    case factory
    when :budget then new_admin_budgets_wizard_budget_path
    when :budget_investment
      [
        new_budget_investment_path(budget_id: imageable.budget_id),
        new_management_budget_investment_path(budget_id: imageable.budget_id)
      ].sample
    when :future_poll_question_option then new_admin_option_image_path(option_id: imageable.id)
    when :proposal then [new_proposal_path, edit_proposal_path(imageable)].sample
    end
  end
  let(:submit_button_text) do
    case factory
    when :budget then "Continue to groups"
    when :budget_investment then "Create Investment"
    when :future_poll_question_option then "Save image"
    when :proposal
      if edit_path?
        "Save changes"
      else
        "Create proposal"
      end
    end
  end
  let(:notice_text) do
    case factory
    when :budget then "New participatory budget created successfully!"
    when :budget_investment then "Budget Investment created successfully."
    when :future_poll_question_option then "Image uploaded successfully"
    when :proposal
      if edit_path?
        "Proposal updated successfully"
      else
        "Proposal created successfully"
      end
    end
  end

  context "New and edit path" do
    before do
      create(:administrator, user: user) if admin_section? || management_section?
      imageable.update!(author: user) if edit_path?
      do_login_for(user, management: management_section?)
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
      input_title = find(".image-fields input[name$='[title]']")
      fill_in input_title[:id], with: "Title"
      attach_file "Choose image", file_fixture("clippy.jpg")

      if factory == :future_poll_question_option
        expect(find("input[id$='_title']").value).to eq "Title"
      else
        expect(find("##{factory}_image_attributes_title").value).to eq "Title"
      end
    end

    scenario "Should update image cached_attachment field after valid file upload" do
      click_link "Add image"

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)
      expect(cached_attachment_field.value).to be_empty

      attach_file "Choose image", file_fixture("clippy.jpg")

      expect(page).to have_css(".loading-bar.complete")
      expect(cached_attachment_field.value).not_to be_empty
    end

    scenario "Should not update image cached_attachment field after invalid file upload" do
      imageable_attach_new_file(file_fixture("logo_header.png"), false)

      cached_attachment_field = find("input[name$='[cached_attachment]']", visible: :hidden)

      expect(cached_attachment_field.value).to be_empty
    end

    scenario "Should show image errors after invalid form submit" do
      click_link "Add image"
      click_button submit_button_text

      within "#nested-image .image-fields" do
        expect(page).to have_content("can't be blank", count: 2)
      end
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
        fill_in_required_fields

        click_button submit_button_text

        expect(page).to have_content notice_text
      end
    end

    scenario "Should show successful notice when resource filled correctly and after valid file uploads" do
      fill_in_required_fields

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      click_button submit_button_text

      expect(page).to have_content notice_text
    end

    scenario "Should show new image after successful creation with one uploaded file" do
      fill_in_required_fields

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

  def fill_in_required_fields
    return if edit_path?

    case factory
    when :budget then fill_budget
    when :budget_investment then fill_budget_investment
    when :proposal then fill_proposal
    end
  end

  def fill_proposal
    fill_in_new_proposal_title with: "Proposal title"
    fill_in "Proposal summary", with: "Proposal summary"
    check :proposal_terms_of_service
  end

  def fill_budget
    fill_in "Name", with: "Budget name"
  end

  def fill_budget_investment
    fill_in_new_investment_title with: "Budget investment title"
    fill_in_ckeditor "Description", with: "Budget investment description"
    check :budget_investment_terms_of_service
  end

  def admin_section?
    path.starts_with?("/admin/")
  end

  def management_section?
    path.starts_with?("/management/")
  end

  def edit_path?
    path.ends_with?("/edit")
  end
end
