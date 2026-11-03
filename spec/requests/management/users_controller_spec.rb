require "rails_helper"

describe Management::UsersController do
  describe "POST /management/users" do
    it "does not create two records with two simultaneous requests", :race_condition, :admin do
      path = management_users_path

      with_sleep_after_validations(User) do
        statuses = 2.times.map do |n|
          Thread.new do
            post path, params: { user: {
              document_type: "1",
              document_number: "12345678Z",
              username: "user#{n}"
            }}
          end
        end.map(&:value)

        expect(statuses).to eq [200, 200]
        expect(User.by_document("1", "12345678Z").count).to eq 1
      end
    end
  end
end
