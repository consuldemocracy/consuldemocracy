require 'rails_helper'

RSpec.describe Admin::EventsController, type: :controller do
  # Assuming you have an Admin login helper (Devise or similar)
  # If not, remove the `sign_in` line.
  let(:admin) { create(:administrator) }
  before { sign_in admin }

  let!(:event) { create(:event) }
  let(:valid_attributes) do
    {
      name: "New Strategy Meeting",
      starts_at: Time.current + 1.day,
      ends_at: Time.current + 2.days,
      event_type: "workshop",
      description: "Discussing the future."
    }
  end

  let(:invalid_attributes) do
    { name: "", starts_at: nil }
  end

  describe "GET #index" do
    it "returns success and assigns events" do
      get :index
      expect(response).to be_successful
      expect(assigns(:events)).to include(event)
    end
  end

  describe "GET #new" do
    it "assigns a new event" do
      get :new
      expect(assigns(:event)).to be_a_new(Event)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Event" do
        expect {
          post :create, params: { event: valid_attributes }
        }.to change(Event, :count).by(1)
      end

      it "redirects to the index page" do
        post :create, params: { event: valid_attributes }
        expect(response).to redirect_to(admin_events_path)
        expect(flash[:notice]).to eq("Event created successfully.")
      end
    end

    context "with invalid params" do
      it "does not create a new Event" do
        expect {
          post :create, params: { event: invalid_attributes }
        }.not_to change(Event, :count)
      end

      it "re-renders the new template" do
        post :create, params: { event: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested event" do
      get :edit, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
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
        put :update, params: { id: event.id, event: { name: nil } }
        event.reload
        expect(event.name).not_to be_nil
      end

      it "re-renders the edit template" do
        put :update, params: { id: event.id, event: { name: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested event" do
      expect {
        delete :destroy, params: { id: event.id }
      }.to change(Event, :count).by(-1)
    end

    it "redirects to the events list" do
      delete :destroy, params: { id: event.id }
      expect(response).to redirect_to(admin_events_path)
      expect(flash[:notice]).to eq("Event deleted.")
    end
  end
end
