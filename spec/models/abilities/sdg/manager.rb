require "rails_helper"
require "cancan/matchers"

describe "Abilities::SDG::Manager" do
  subject(:ability) { Ability.new(user) }

  let(:user) { sdg_manager.user }
  let(:sdg_manager) { create(:sdg_manager) }

  it { should be_able_to(:read, SDG::Goal) }
  it { should be_able_to(:read, SDG::Target) }
  it { should be_able_to(:manage, SDG::LocalTarget) }

  it { should_not be_able_to(:read, SDG::Manager) }
  it { should_not be_able_to(:create, SDG::Manager) }
  it { should_not be_able_to(:delete, SDG::Manager) }
end
