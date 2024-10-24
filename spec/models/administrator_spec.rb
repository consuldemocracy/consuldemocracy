require "rails_helper"

describe Administrator do
  describe "#description_or_name" do
    let!(:user) { create(:user, username: "Billy Wilder") }

    it "returns description if present" do
      administrator = create(:administrator, user: user, description: "John Doe")

      expect(administrator.description_or_name).to eq("John Doe")
    end

    it "returns name if description is nil" do
      administrator = create(:administrator, user: user)

      expect(administrator.description_or_name).to eq("Billy Wilder")
    end

    it "returns name if description is blank" do
      administrator = create(:administrator, description: "")

      expect(administrator.description_or_name).to eq(administrator.name)
    end
  end

  describe "#description_or_name_and_email" do
    let!(:user) { create(:user, username: "Billy Wilder", email: "test@test.com") }

    it "returns description and email if decription present" do
      administrator = create(:administrator, description: "John Doe", user: user)

      expect(administrator.description_or_name_and_email).to eq("John Doe (test@test.com)")
    end

    it "returns name and email if description is not present" do
      administrator = create(:administrator, user: user)

      expect(administrator.description_or_name_and_email).to eq("Billy Wilder (test@test.com)")
    end
  end

  describe "#destroy" do
    it "removes dependent budget administrator records" do
      administrator = create(:administrator)
      create_list(:budget, 2, administrators: [administrator])

      expect { administrator.destroy }.to change { BudgetAdministrator.count }.by(-2)
    end
  end
end
