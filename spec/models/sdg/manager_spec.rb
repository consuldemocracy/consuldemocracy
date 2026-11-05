require "rails_helper"

describe SDG::Manager do
  describe "validations" do
    it "is not valid if the user is already an SDG manager" do
      manager = create(:sdg_manager)

      expect(build(:sdg_manager, user: manager.user)).not_to be_valid
    end

    it "raises a RecordNotUnique exception when there are duplicate SDG managers" do
      manager = create(:sdg_manager)
      duplicate = build(:sdg_manager, user: manager.user)

      expect { duplicate.save(validate: false) }.to raise_error ActiveRecord::RecordNotUnique
    end
  end
end
