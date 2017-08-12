require 'rails_helper'

describe Admin::Api::StatsController do

  describe 'GET index' do
    let(:user) { create(:administrator).user }

    context 'events or visits not present' do
      it 'should respond with bad_request' do
        sign_in user
        get :show

        expect(response).to_not be_ok
        expect(response.status).to eq 400
      end
    end

    context 'events present' do
      before :each do
        time_1 = DateTime.parse("2015-01-01").in_time_zone
        time_2 = DateTime.parse("2015-01-02").in_time_zone
        time_3 = DateTime.parse("2015-01-03").in_time_zone

        create :ahoy_event, name: 'foo', time: time_1
        create :ahoy_event, name: 'foo', time: time_1
        create :ahoy_event, name: 'foo', time: time_2
        create :ahoy_event, name: 'bar', time: time_1
        create :ahoy_event, name: 'bar', time: time_3
        create :ahoy_event, name: 'bar', time: time_3
      end

      it 'should return single events formated for working with c3.js' do
        sign_in user
        get :show, events: 'foo'

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2015-01-01", "2015-01-02"], "Foo" => [2, 1]
      end

      it 'should return combined comma separated events formated for working with c3.js' do
        sign_in user
        get :show, events: 'foo,bar'

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2015-01-01", "2015-01-02", "2015-01-03"], "Foo" => [2, 1, 0], "Bar" => [1, 0, 2]
      end
    end

    context 'visits present' do
      it 'should return visits formated for working with c3.js' do
        time_1 = DateTime.parse("2015-01-01").in_time_zone
        time_2 = DateTime.parse("2015-01-02").in_time_zone

        create :visit, started_at: time_1
        create :visit, started_at: time_1
        create :visit, started_at: time_2

        sign_in user
        get :show, visits: true

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2015-01-01", "2015-01-02"], "Visits" => [2, 1]
      end
    end

    context 'visits and events present' do
      it 'should return combined events and visits formated for working with c3.js' do
        time_1 = DateTime.parse("2015-01-01").in_time_zone
        time_2 = DateTime.parse("2015-01-02").in_time_zone

        create :ahoy_event, name: 'foo', time: time_1
        create :ahoy_event, name: 'foo', time: time_2
        create :ahoy_event, name: 'foo', time: time_2

        create :visit, started_at: time_1
        create :visit, started_at: time_1
        create :visit, started_at: time_2

        sign_in user
        get :show, events: 'foo', visits: true

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2015-01-01", "2015-01-02"], "Foo" => [1, 2], "Visits" => [2, 1]
      end
    end

    context 'budget investments present' do
      it 'should return budget investments formated for working with c3.js' do
        time_1 = DateTime.parse("2017-04-01").in_time_zone
        time_2 = DateTime.parse("2017-04-02").in_time_zone

        budget_investment1 = create(:budget_investment, budget: @budget, created_at: time_1)
        budget_investment2 = create(:budget_investment, budget: @budget, created_at: time_2)
        budget_investment3 = create(:budget_investment, budget: @budget, created_at: time_2)

        sign_in user
        get :show, budget_investments: true

        expect(response).to be_ok

        data = JSON.parse(response.body)
        expect(data).to eq "x" => ["2017-04-01", "2017-04-02"], "Budget Investments" => [1, 2]
      end
    end
  end
end
