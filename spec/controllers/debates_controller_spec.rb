require 'rails_helper'

describe DebatesController do

  before(:all) do
    @original_captcha_pass_value = SimpleCaptcha.always_pass
    SimpleCaptcha.always_pass = true
  end

  after(:all) do
    SimpleCaptcha.always_pass = @original_captcha_pass_value
  end

  describe 'POST create' do
    it 'should create an ahoy event' do

      sign_in create(:user)

      post :create, debate: { title: 'A sample debate', description: 'this is a sample debate', terms_of_service: 1 }
      expect(Ahoy::Event.where(name: :debate_created).count).to eq 1
      expect(Ahoy::Event.last.properties['debate_id']).to eq Debate.last.id

      post :create, medida: { title: 'A sample measure', description: 'this is a sample measure', terms_of_service: 1 }
      expect(Ahoy::Event.where(name: :measure_created).count).to eq 1
      expect(Ahoy::Event.last.properties['measure_id']).to eq Measure.last.id
    end
  end

  describe "Vote with too many anonymous votes" do
    it 'should allow vote if user is allowed' do
      Setting.find_by(key: "max_ratio_anon_votes_on_debates").update(value: 100)
      debate = create(:debate)
      sign_in create(:user)

      expect do
        xhr :post, :vote, id: debate.id, value: 'yes'
      end.to change { debate.reload.votes_for.size }.by(1)
    end

    it 'should not allow vote if user is not allowed' do
      Setting.find_by(key: "max_ratio_anon_votes_on_debates").update(value: 0)
      debate = create(:debate, cached_votes_total: 1000)
      sign_in create(:user)

      expect do
        xhr :post, :vote, id: debate.id, value: 'yes'
      end.to_not change { debate.reload.votes_for.size }
    end
  end
end
