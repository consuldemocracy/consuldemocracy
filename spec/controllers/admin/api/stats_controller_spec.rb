require "rails_helper"

describe Admin::Api::StatsController, :admin do
  describe "GET index" do
    context "events or visits not present" do
      it "responds with bad_request" do
        get :show

        expect(response).not_to be_ok
        expect(response.status).to eq 400
      end
    end

    context "events present" do
      before do
        time_1 = Time.zone.local(2015, 01, 01)
        time_2 = Time.zone.local(2015, 01, 02)
        time_3 = Time.zone.local(2015, 01, 03)

        create :ahoy_event, name: "foo", time: time_1
        create :ahoy_event, name: "foo", time: time_1
        create :ahoy_event, name: "foo", time: time_2
        create :ahoy_event, name: "bar", time: time_1
        create :ahoy_event, name: "bar", time: time_3
        create :ahoy_event, name: "bar", time: time_3
      end

      it "returns single events formated for working with c3.js" do
        get :show, params: { event: "foo" }

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2015-01-01", "2015-01-02"], "Foo" => [2, 1]
      end
    end

    context "visits present" do
      it "returns visits formated for working with c3.js" do
        time_1 = Time.zone.local(2015, 01, 01)
        time_2 = Time.zone.local(2015, 01, 02)

        create :visit, started_at: time_1
        create :visit, started_at: time_1
        create :visit, started_at: time_2

        get :show, params: { visits: true }

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2015-01-01", "2015-01-02"], "Visits" => [2, 1]
      end
    end

    context "budget investments present" do
      it "returns budget investments formated for working with c3.js" do
        time_1 = Time.zone.local(2017, 04, 01)
        time_2 = Time.zone.local(2017, 04, 02)

        create(:budget_investment, created_at: time_1)
        create(:budget_investment, created_at: time_2)
        create(:budget_investment, created_at: time_2)

        get :show, params: { budget_investments: true }

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2017-04-01", "2017-04-02"], "Budget Investments" => [1, 2]
      end
    end
  end
end
