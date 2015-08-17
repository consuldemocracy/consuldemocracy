require 'rails_helper'

describe DebatesController do

  # create
  #----------------------------------------------------------------------

  describe 'POST create' do
    let(:user) { create :user }

    it 'should create an ahoy event' do
      sign_in user
      post :create, debate: { title: 'foo', description: 'foo bar', terms_of_service: 1  }
      expect(Ahoy::Event.where(name: :debate_created).count).to eq 1
      expect(Ahoy::Event.last.properties['debate_id']).to eq Debate.last.id
    end
  end
end
