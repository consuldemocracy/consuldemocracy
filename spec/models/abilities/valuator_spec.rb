require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Valuator" do
  subject(:ability) { Ability.new(user) }
  let(:user) { valuator.user }
  let(:valuator) { create(:valuator) }

  it { should be_able_to(:manage, SpendingProposal) }
end
