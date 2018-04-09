require 'rails_helper'
require 'cancan/matchers'

describe Abilities::Common do
  subject(:ability) { Ability.new(user) }

  let(:geozone)     { create(:geozone)  }
  let(:user) { create(:user, geozone: geozone) }
  let(:debate)       { create(:debate)   }
  let(:own_debate)   { create(:debate,   author: user) }

  describe "destroying debates" do
    let(:own_debate_non_destroyable) { create(:debate, author: user) }

    before { allow(own_debate_non_destroyable).to receive(:destroyable?).and_return(false) }

    it { should be_able_to(:destroy, own_debate)              }
    it { should_not be_able_to(:destroy, debate)                  } # Not his
    it { should_not be_able_to(:destroy, own_debate_non_destroyable) }
  end

end
