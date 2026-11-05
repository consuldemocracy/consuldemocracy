require "rails_helper"

describe "identities tasks" do
  describe "identities:remove_duplicate_identities" do
    before { Rake::Task["identities:remove_duplicate_identities"].reenable }

    it "keeps the first identity with a user" do
      user = create(:user)

      Identity.insert!({ provider: "twitter", uid: "12345", user_id: nil })
      Identity.insert!({ provider: "twitter", uid: "12345", user_id: user.id })
      Identity.insert!({ provider: "twitter", uid: "12345", user_id: user.id })
      Identity.insert!({ provider: "facebook", uid: "abc" })

      oldest_id_with_user = Identity.where(provider: "twitter", uid: "12345", user: user).order(:id).first.id

      Rake.application.invoke_task("identities:remove_duplicate_identities")

      expect(Identity.where(provider: "twitter", uid: "12345").ids).to eq [oldest_id_with_user]
      expect(Identity.where(provider: "facebook", uid: "abc").count).to eq 1
    end

    it "keeps the oldest identity when none have a user" do
      2.times { Identity.insert!({ provider: "twitter", uid: "12345" }) }
      oldest_id = Identity.where(provider: "twitter", uid: "12345").order(:id).first.id

      Rake.application.invoke_task("identities:remove_duplicate_identities")

      expect(Identity.where(provider: "twitter", uid: "12345").ids).to eq [oldest_id]
    end

    it "keeps duplicate identities assigned to different users" do
      user1 = create(:user)
      user2 = create(:user)

      Identity.insert!({ provider: "twitter", uid: "12345", user_id: user1.id })
      Identity.insert!({ provider: "twitter", uid: "12345", user_id: user2.id })

      Rake.application.invoke_task("identities:remove_duplicate_identities")

      identities = Identity.where(provider: "twitter", uid: "12345")

      expect(identities.count).to eq 2
      expect(identities.pluck(:user_id)).to match_array [user1.id, user2.id]
    end

    it "deletes duplicates of the same user but keeps identities assigned to a different user" do
      user1 = create(:user)
      user2 = create(:user)

      Identity.insert!({ provider: "twitter", uid: "12345", user_id: user1.id })
      Identity.insert!({ provider: "twitter", uid: "12345", user_id: user1.id })
      Identity.insert!({ provider: "twitter", uid: "12345", user_id: user2.id })

      Rake.application.invoke_task("identities:remove_duplicate_identities")

      identities = Identity.where(provider: "twitter", uid: "12345")

      expect(identities.count).to eq 2
      expect(identities.pluck(:user_id)).to match_array [user1.id, user2.id]
    end

    it "removes duplicate identities on tenants" do
      create(:tenant, schema: "identities")

      Tenant.switch("identities") do
        2.times { Identity.insert!({ provider: "twitter", uid: "12345" }) }

        expect(Identity.where(provider: "twitter", uid: "12345").count).to eq 2
      end

      Rake.application.invoke_task("identities:remove_duplicate_identities")

      Tenant.switch("identities") do
        expect(Identity.where(provider: "twitter", uid: "12345").count).to eq 1
      end
    end
  end
end
