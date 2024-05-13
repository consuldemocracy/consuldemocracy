require "rails_helper"

describe "Images", :admin do
  let(:future_poll) { create(:poll, :future) }
  let(:current_poll) { create(:poll) }

  it_behaves_like "nested imageable",
                  "future_poll_question_option",
                  "new_admin_option_image_path",
                  { option_id: "id" },
                  nil,
                  "Save image",
                  "Image uploaded successfully",
                  true

  context "Index" do
    scenario "Option with no images" do
      option = create(:poll_question_option)

      visit admin_option_images_path(option)

      expect(page).not_to have_css("img[title='']")
    end

    scenario "Option with images" do
      option = create(:poll_question_option)
      image = create(:image, imageable: option)

      visit admin_option_images_path(option)

      expect(page).to have_css("img[title='#{image.title}']")
      expect(page).to have_content(image.title)
    end
  end

  describe "Add image to option" do
    scenario "Is possible for a not started poll" do
      option = create(:poll_question_option, poll: future_poll)

      visit admin_option_images_path(option)

      expect(page).not_to have_css "img[title='clippy.jpg']"
      expect(page).not_to have_content "clippy.jpg"

      click_link "Add image"
      expect(page).to have_content "Descriptive image"

      imageable_attach_new_file(file_fixture("clippy.jpg"))
      click_button "Save image"

      expect(page).to have_content "Image uploaded successfully"
      expect(page).to have_css "img[title='clippy.jpg']"
      expect(page).to have_content "clippy.jpg"
    end

    scenario "Is not possible for an already started poll" do
      option = create(:poll_question_option, poll: current_poll)

      visit admin_option_images_path(option)

      expect(page).not_to have_link "Add image"
      expect(page).to have_content "Once the poll has started it will not be possible to create, edit or"
    end
  end

  describe "Remove image from option" do
    scenario "Is possible for a not started poll" do
      option = create(:poll_question_option, poll: future_poll)
      image = create(:image, imageable: option)

      visit admin_option_images_path(option)
      expect(page).to have_css "img[title='#{image.title}']"
      expect(page).to have_content image.title

      accept_confirm "Are you sure? Remove image \"#{image.title}\"" do
        click_button "Remove image"
      end

      expect(page).not_to have_css "img[title='#{image.title}']"
      expect(page).not_to have_content image.title
    end

    scenario "Is not possible for an already started poll" do
      option = create(:poll_question_option, poll: current_poll)
      image = create(:image, imageable: option)

      visit admin_option_images_path(option)
      expect(page).to have_css "img[title='#{image.title}']"
      expect(page).to have_content image.title

      expect(page).not_to have_content "Remove image"
      expect(page).to have_content "Once the poll has started it will not be possible to create, edit or"
    end
  end
end
