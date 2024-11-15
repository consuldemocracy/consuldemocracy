require "rails_helper"

describe "Nested imageable" do
  factories = [
    :budget
  ]

  let(:factory) { factories.sample }
  let!(:imageable) { create(factory) }
  let!(:user) { create(:administrator).user }
  let(:path) { new_admin_budgets_wizard_budget_path }
  let(:submit_button_text) { "Continue to groups" }
  let(:notice_text) { "New participatory budget created successfully!" }

  before do
    login_as(user)
    visit path
  end

  scenario "Should show new image link when imageable has not an associated image defined" do
    expect(page).to have_css "#new_image_link"
  end

  scenario "Should hide new image link after adding one image" do
    click_link "Add image"

    expect(page).not_to have_css "#new_image_link"
  end

  scenario "Should update image file name after choosing any file" do
    click_link "Add image"
    attach_file "Choose image", file_fixture("clippy.jpg")

    expect(page).to have_css ".file-name", text: "clippy.jpg"
  end

  scenario "Should update image file title after choosing a file when no title is defined" do
    imageable_attach_new_file(file_fixture("clippy.jpg"))

    expect_image_has_title("clippy.jpg")
  end

  scenario "Should not update image file title after choosing a file when a title is already defined" do
    click_link "Add image"
    input_title = find(".image-fields input[name$='[title]']")
    fill_in input_title[:id], with: "Title"
    attach_file "Choose image", file_fixture("clippy.jpg")

    expect(find("##{factory}_image_attributes_title").value).to eq "Title"
  end

  scenario "Should update loading bar style after valid file upload" do
    imageable_attach_new_file(file_fixture("clippy.jpg"))

    expect(page).to have_css ".loading-bar.complete"
  end

  scenario "Should update loading bar style after invalid file upload" do
    imageable_attach_new_file(file_fixture("logo_header.png"), false)

    expect(page).to have_css ".loading-bar.errors"
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

  scenario "Should show successful notice when resource filled correctly without any nested images" do
    imageable_fill_new_valid_budget

    click_button submit_button_text

    expect(page).to have_content notice_text
  end

  scenario "Should show successful notice when resource filled correctly and after valid file uploads" do
    imageable_fill_new_valid_budget

    imageable_attach_new_file(file_fixture("clippy.jpg"))

    expect(page).to have_css ".loading-bar.complete"

    click_button submit_button_text

    expect(page).to have_content notice_text
  end

  scenario "Should show new image after successful creation with one uploaded file" do
    imageable_fill_new_valid_budget

    imageable_attach_new_file(file_fixture("clippy.jpg"))

    expect(page).to have_css ".loading-bar.complete"

    click_button submit_button_text

    expect(page).to have_content notice_text

    redirected_to_resource_show_or_navigate_to(imageable)

    expect(page).to have_css "figure img"
    expect(page).to have_css "figure figcaption" if show_caption_for?(factory)
  end

  scenario "Different URLs for different images" do
    imageable_attach_new_file(file_fixture("clippy.jpg"))

    original_src = find(:fieldset, "Descriptive image").find("img")[:src]

    click_link "Remove image"
    imageable_attach_new_file(file_fixture("custom_map.jpg"))

    updated_src = find(:fieldset, "Descriptive image").find("img")[:src]

    expect(updated_src).not_to eq original_src
  end

  def show_caption_for?(factory)
    factory != :budget
  end

  def expect_image_has_title(title)
    image = find(".image-fields")

    within image do
      expect(find("input[name$='[title]']").value).to eq title
    end
  end

  def redirected_to_resource_show_or_navigate_to(imageable)
    case imageable.class.to_s
    when "Budget"
      visit edit_admin_budget_path(Budget.last)
    when "Proposal"
      click_link "Not now, go to my proposal" rescue Capybara::ElementNotFound
    end
  end
end
