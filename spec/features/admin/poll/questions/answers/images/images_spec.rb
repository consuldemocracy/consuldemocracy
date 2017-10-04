require 'rails_helper'

feature 'Images' do

	background do
		admin = create(:administrator)
		login_as(admin.user)
	end

	scenario "Index" do
	end

	scenario "Create", :js do
		question = create(:poll_question)
		answer = create(:poll_question_answer, question: question)

		visit admin_question_path(question)

		within("#poll_question_answer_#{answer.id}") do
			click_link "Lista de imágenes"
		end

		click_link "Add image"

		imageable_attach_new_file(:poll_question_answer, "spec/fixtures/files/clippy.jpg")
    click_button "Save image"

    expect(page).to have_content "Image uploaded successfully"
	end

end