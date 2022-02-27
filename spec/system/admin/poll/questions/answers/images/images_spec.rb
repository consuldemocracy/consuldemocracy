require "rails_helper"

describe "Images", :admin do
  let(:future_poll) { create(:poll) }
  let(:current_poll) { create(:poll, :current) }

  it_behaves_like "nested imageable",
                  "poll_question_answer",
                  "new_admin_answer_image_path",
                  { answer_id: "id" },
                  nil,
                  "Save image",
                  "Image uploaded successfully",
                  true

  context "Index" do
    scenario "Answer with no images" do
      answer = create(:poll_question_answer)

      visit admin_answer_images_path(answer)

      expect(page).not_to have_css("img[title='']")
    end

    scenario "Answer with images" do
      answer = create(:poll_question_answer)
      image = create(:image, imageable: answer)

      visit admin_answer_images_path(answer)

      expect(page).to have_css("img[title='#{image.title}']")
      expect(page).to have_content(image.title)
    end
  end

  context "Add image to answer" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Images list"
      end

      expect(page).not_to have_css("img[title='clippy.jpg']")
      expect(page).not_to have_content("clippy.jpg")

      click_link "Add image"
      expect(page).to have_content "Descriptive image"

      imageable_attach_new_file(Rails.root.join("spec/fixtures/files/clippy.jpg"))
      click_button "Save image"

      expect(page).to have_content "Image uploaded successfully"
      expect(page).to have_css("img[title='clippy.jpg']")
      expect(page).to have_content("clippy.jpg")

      expect(answer.images).not_to be_empty
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_answer_images_path(answer)
      expect(page).not_to have_css("img[title='clippy.jpg']")
      expect(page).not_to have_content("clippy.jpg")

      visit new_admin_answer_image_path(answer)
      imageable_attach_new_file(file_fixture("clippy.jpg"))
      click_button "Save image"

      expect(page).to have_content "It is not possible to modify answers for an already started poll."

      expect(answer.images).to be_empty
    end
  end

  context "Remove image from answer" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)
      image = create(:image, imageable: answer)

      visit admin_answer_images_path(answer)
      expect(page).to have_css("img[title='#{image.title}']")
      expect(page).to have_content(image.title)

      accept_confirm "Are you sure? Remove image \"#{image.title}\"" do
        click_link "Remove image"
      end

      expect(page).not_to have_css("img[title='#{image.title}']")
      expect(page).not_to have_content(image.title)

      expect(answer.images).to be_empty
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)
      image = create(:image, imageable: answer)

      visit admin_answer_images_path(answer)
      expect(page).to have_css("img[title='#{image.title}']")
      expect(page).to have_content(image.title)

      accept_confirm { click_link "Remove image" }

      expect(page).to have_content "It is not possible to modify answers for an already started poll."

      expect(answer.images).not_to be_empty
    end
  end
end
