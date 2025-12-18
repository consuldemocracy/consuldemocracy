require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let!(:event) { create(:event) }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @start_date" do
      get :index
      expect(assigns(:start_date)).to eq(Date.current)
    end

    it "accepts a valid start_date param" do
      specific_date = "2025-05-01"
      get :index, params: { start_date: specific_date }
      expect(assigns(:start_date)).to eq(Date.parse(specific_date))
    end

    it "assigns @calendar_items" do
      get :index
      # Since our factory event is for tomorrow, it should be in the current month list
      expect(assigns(:calendar_items)).to include(event)
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      get :show, params: { id: event.id }
      expect(response).to be_successful
    end

    it "assigns the requested event to @event" do
      get :show, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
    end
  end
end
