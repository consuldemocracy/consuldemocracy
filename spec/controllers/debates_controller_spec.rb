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

      post :create, debate: { title: 'foo', description: 'foo bar', terms_of_service: 1 }
      expect(Ahoy::Event.where(name: :debate_created).count).to eq 1
      expect(Ahoy::Event.last.properties['debate_id']).to eq Debate.last.id
    end
  end
end
