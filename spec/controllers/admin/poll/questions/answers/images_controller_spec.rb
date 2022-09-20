require "rails_helper"

describe Admin::Poll::Questions::Answers::ImagesController, :admin do
  let(:current_answer) { create(:poll_question_answer, poll: create(:poll)) }
  let(:future_answer) { create(:poll_question_answer, poll: create(:poll, :future)) }

  describe "POST create" do
    let(:answer_attributes) do
      {
        images_attributes: {
          "0" => {
            attachment: fixture_file_upload("clippy.jpg"),
            title: "Title",
            user_id: User.last.id
          }
        }
      }
    end

    it "is not possible for an already started poll" do
      post :create, params: { poll_question_answer: answer_attributes, answer_id: current_answer }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Answer."
      expect(Image.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: { poll_question_answer: answer_attributes, answer_id: future_answer }

      expect(response).to redirect_to admin_answer_images_path(future_answer)
      expect(flash[:notice]).to eq "Image uploaded successfully"
      expect(Image.count).to eq 1
    end
  end

  describe "DELETE destroy" do
    it "is not possible for an already started poll" do
      current_image = create(:image, imageable: current_answer)
      delete :destroy, xhr: true, params: { id: current_image }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Image."
      expect(Image.count).to eq 1
    end

    it "is possible for a not started poll" do
      future_image = create(:image, imageable: future_answer)
      delete :destroy, xhr: true, params: { id: future_image }

      expect(Image.count).to eq 0
    end
  end
end
