require 'rails_helper'

describe Manager do

  describe "valid?" do

    let(:manager) { create(:manager) }

    it "is false when username is blank" do
      manager.username = nil
      expect(manager).to_not be_valid
    end
    it "is false when password is blank" do
      manager.password_digest = nil
      expect(manager).to_not be_valid
    end

    it "is true if username and password present" do
      expect(manager).to be_valid
    end
  end

  describe "self.valid_manager" do
    before(:all) { create(:manager, username: "Silvia" ,password: "supersecret") }

    it "is false when username is blank" do
      expect(Manager.valid_manager(nil, "supersecret")).to be_blank
    end
    it "is false when password is blank" do
      expect(Manager.valid_manager("Silvia", nil)).to be_blank
    end

    it "is false if manager unexistent" do
      expect(Manager.valid_manager("Manager", "supersecret")).to be_blank
    end

    it "is false if wrong password unexistent" do
      expect(Manager.valid_manager("Silvia", "wrong")).to be_blank
    end

    it "is true if right username/password combination" do
      expect(Manager.valid_manager("Silvia", "supersecret")).to be_present
    end
  end

end