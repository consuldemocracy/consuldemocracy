require "rails_helper"

describe Admin::Api::StatsController, :admin do
  describe "GET index" do
    context "events or visits not present" do
      it "responds with bad_request" do
        get :show

        expect(response).not_to be_ok
        expect(response).to have_http_status 400
      end
    end

    context "events present" do
      before do
        time_1 = Time.zone.local(2015, 01, 01)
        time_2 = Time.zone.local(2015, 01, 02)
        time_3 = Time.zone.local(2015, 01, 03)

        create(:proposal, created_at: time_1)
        create(:proposal, created_at: time_1)
        create(:proposal, created_at: time_2)
        create(:debate, created_at: time_1)
        create(:debate, created_at: time_3)
        create(:debate, created_at: time_3)
      end

      it "returns single events formated for working with c3.js" do
        get :show, params: { event: "proposal_created" }

        expect(response).to be_ok
        expect(response.parsed_body).to eq "x" => ["2015-01-01", "2015-01-02"], "Citizen proposals created" => [2, 1]
      end
    end
  end
end
