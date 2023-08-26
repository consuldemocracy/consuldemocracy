require "rails_helper"

describe DocumentsController do
  describe "DELETE destroy" do
    context "Poll answers administration", :admin do
      let(:current_answer) { create(:poll_question_answer, poll: create(:poll)) }
      let(:future_answer) { create(:poll_question_answer, poll: create(:poll, :future)) }

      it "is not possible for an already started poll" do
        document = create(:document, documentable: current_answer)
        delete :destroy, params: { id: document }

        expect(flash[:alert]).to eq "You do not have permission to carry out the action 'destroy' on Document."
        expect(Document.count).to eq 1
      end

      it "is possible for a not started poll" do
        document = create(:document, documentable: future_answer)
        request.env["HTTP_REFERER"] = admin_answer_documents_path(future_answer)
        delete :destroy, params: { id: document }

        expect(response).to redirect_to admin_answer_documents_path(future_answer)
        expect(flash[:notice]).to eq "Document was deleted successfully."
        expect(Document.count).to eq 0
      end
    end
  end
end
