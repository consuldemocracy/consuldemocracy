require 'rails_helper'

describe Api::StatsController do

  # GET index
  #----------------------------------------------------------------------

  describe 'GET index' do
    let(:user) { create :user }

    context 'event not present' do
      it 'should respond with bad_request' do
        sign_in user
        get :show
        expect(response.status).to eq 400
      end
    end

    context 'event present' do
      it 'should return event counts' do
        time_1 = DateTime.yesterday.to_datetime
        time_2 = DateTime.now

        event_1 = create :ahoy_event, name: 'foo', time: time_1
        event_2 = create :ahoy_event, name: 'foo', time: time_1
        event_3 = create :ahoy_event, name: 'foo', time: time_2
        event_4 = create :ahoy_event, name: 'bar'

        sign_in user
        get :show, event: 'foo'

        expect(response).to be_ok

        data = JSON.parse(response.body)
        dates = data.keys

        expect(DateTime.parse dates.first).to eq time_1.utc.beginning_of_day
        expect(DateTime.parse dates.last).to eq time_2.utc.beginning_of_day
        expect(data[dates.first]).to eq 2
        expect(data[dates.last]).to eq 1
      end
    end
  end
end
