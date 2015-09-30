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

  describe "self.valid_auth?" do
    before(:all) { create(:manager, username: "Silvia" ,password: "supersecret") }

    it "is false when username is blank" do
      expect(Manager.valid_auth?(nil, "supersecret")).to be false
    end
    it "is false when password is blank" do
      expect(Manager.valid_auth?("Silvia", nil)).to be false
    end

    it "is false if manager unexistent" do
      expect(Manager.valid_auth?("Manager", "supersecret")).to be false
    end

    it "is false if wrong password unexistent" do
      expect(Manager.valid_auth?("Silvia", "wrong")).to be false
    end

    it "is true if right username/password combination" do
      expect(Manager.valid_auth?("Silvia", "supersecret")).to be true
    end
  end

end