require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Officing::Voter" do
  subject(:ability) { Ability.new(user) }
  let(:user)  { voter }
  let(:voter) { create(:user, officing_voter: true) }

  it { should be_able_to(:new, Poll::Nvote) }
  it { should be_able_to(:thanks, Poll::Nvote) }
end
