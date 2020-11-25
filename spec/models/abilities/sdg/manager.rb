require "rails_helper"
require "cancan/matchers"

describe "Abilities::SDG::Manager" do
  subject(:ability) { Ability.new(user) }

  let(:user) { sdg_manager.user }
  let(:sdg_manager) { create(:sdg_manager) }

  it { should be_able_to(:read, SDG::Goal) }
  it { should be_able_to(:read, SDG::Target) }
end
