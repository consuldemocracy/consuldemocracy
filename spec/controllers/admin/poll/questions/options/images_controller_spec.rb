require "rails_helper"

describe Admin::Poll::Questions::Options::ImagesController, :admin do
  let(:current_option) { create(:poll_question_option, poll: create(:poll)) }
  let(:future_option) { create(:poll_question_option, poll: create(:poll, :future)) }

  describe "POST create" do
    let(:option_attributes) do
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
      post :create, params: { poll_question_option: option_attributes, option_id: current_option }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Option."
      expect(Image.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: { poll_question_option: option_attributes, option_id: future_option }

      expect(response).to redirect_to admin_option_images_path(future_option)
      expect(flash[:notice]).to eq "Image uploaded successfully"
      expect(Image.count).to eq 1
    end
  end

  describe "DELETE destroy" do
    it "is not possible for an already started poll" do
      current_image = create(:image, imageable: current_option)
      delete :destroy, xhr: true, params: { id: current_image }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Image."
      expect(Image.count).to eq 1
    end

    it "is possible for a not started poll" do
      future_image = create(:image, imageable: future_option)
      delete :destroy, xhr: true, params: { id: future_image }

      expect(Image.count).to eq 0
    end
  end
end
