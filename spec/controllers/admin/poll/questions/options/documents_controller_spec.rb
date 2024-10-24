require "rails_helper"

describe Admin::Poll::Questions::Options::DocumentsController, :admin do
  let(:current_option) { create(:poll_question_option, poll: create(:poll)) }
  let(:future_option) { create(:poll_question_option, poll: create(:poll, :future)) }

  describe "POST create" do
    let(:option_attributes) do
      {
        documents_attributes: {
          "0" => {
            attachment: fixture_file_upload("clippy.pdf"),
            title: "Title",
            user_id: User.last.id
          }
        }
      }
    end

    it "is not possible for an already started poll" do
      post :create, params: { poll_question_option: option_attributes, option_id: current_option }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action 'update' on Option."
      expect(Document.count).to eq 0
    end

    it "is possible for a not started poll" do
      post :create, params: { poll_question_option: option_attributes, option_id: future_option }

      expect(response).to redirect_to admin_option_documents_path(future_option)
      expect(flash[:notice]).to eq "Document uploaded successfully"
      expect(Document.count).to eq 1
    end
  end
end
