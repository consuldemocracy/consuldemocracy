require "rails_helper"
require "cancan/matchers"

describe "Abilities::SDG::Manager" do
  subject(:ability) { Ability.new(user) }

  let(:user) { sdg_manager.user }
  let(:sdg_manager) { create(:sdg_manager) }

  it { should be_able_to(:read, SDG::Target) }
  it { should be_able_to(:manage, SDG::LocalTarget) }

  it { should_not be_able_to(:read, SDG::Manager) }
  it { should_not be_able_to(:create, SDG::Manager) }
  it { should_not be_able_to(:delete, SDG::Manager) }

  it { should_not be_able_to(:update, create(:widget_card)) }
  it { should be_able_to(:update, create(:widget_card, cardable: SDG::Phase.sample)) }
  it { should_not be_able_to(:create, build(:widget_card)) }
  it { should be_able_to(:create, build(:widget_card, cardable: SDG::Phase.sample)) }
end
