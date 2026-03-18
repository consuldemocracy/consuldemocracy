require "rails_helper"

RSpec.describe Admin::EventsController, :admin do
  let!(:event) { create(:event) }
  let(:valid_attributes) do
    {
      name: "New Strategy Meeting",
      starts_at: 1.day.from_now,
      ends_at: 2.days.from_now,
      event_type: "workshop",
      description: "Discussing the future."
    }
  end
  let(:invalid_attributes) do
    { name: "", starts_at: nil }
  end

  describe "GET #index" do
    it "returns success" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns success" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Event" do
        expect do
          post :create, params: { event: valid_attributes }
        end.to change(Event, :count).by(1)
      end

      it "redirects to the index page" do
        post :create, params: { event: valid_attributes }
        expect(response).to redirect_to(admin_events_path)
        expect(flash[:notice]).to eq("Event created successfully.")
      end
    end

    context "with invalid params" do
      it "does not create a new Event" do
        expect do
          post :create, params: { event: invalid_attributes }
        end.not_to change(Event, :count)
      end

      it "re-renders the new template" do
        post :create, params: { event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #edit" do
    it "returns success" do
      get :edit, params: { id: event.id }
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "Updated Name" } }

      it "updates the requested event" do
        put :update, params: { id: event.id, event: new_attributes }
        event.reload
        expect(event.name).to eq("Updated Name")
      end

      it "redirects to the index page" do
        put :update, params: { id: event.id, event: new_attributes }
        expect(response).to redirect_to(admin_events_path)
        expect(flash[:notice]).to eq("Event updated successfully.")
      end
    end

    context "with invalid params" do
      it "does not update the event" do
        put :update, params: { id: event.id, event: { name: nil }}
        event.reload
        expect(event.name).not_to be(nil)
      end

      it "re-renders the edit template" do
        put :update, params: { id: event.id, event: { name: nil }}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested event" do
      expect do
        delete :destroy, params: { id: event.id }
      end.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      delete :destroy, params: { id: event.id }
      expect(response).to redirect_to(admin_events_path)
      expect(flash[:notice]).to eq("Event deleted.")
    end
  end
end
