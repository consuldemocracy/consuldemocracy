require "rails_helper"

describe DocumentsController do
  describe "DELETE destroy" do
    context "Poll options administration", :admin do
      let(:current_option) { create(:poll_question_option, poll: create(:poll)) }
      let(:future_option) { create(:poll_question_option, poll: create(:poll, :future)) }

      it "is not possible for an already started poll" do
        document = create(:document, documentable: current_option)
        delete :destroy, params: { id: document }

        expect(flash[:alert]).to eq "You do not have permission to " \
                                    "carry out the action 'destroy' on Document."
        expect(Document.count).to eq 1
      end

      it "is possible for a not started poll" do
        document = create(:document, documentable: future_option)
        request.env["HTTP_REFERER"] = admin_option_documents_path(future_option)
        delete :destroy, params: { id: document }

        expect(response).to redirect_to admin_option_documents_path(future_option)
        expect(flash[:notice]).to eq "Document was deleted successfully."
        expect(Document.count).to eq 0
      end
    end
  end
end
