require "rails_helper"

describe "rake users:remove_users_data" do
  it "Remove users data with empty email" do
    user_1 = create(:user, :verified, email: "user@mail.com", document_type: 1, document_number: "12345678Z")
    user_2 = create(:user, :verified, document_type: 1, document_number: "87654321Y")
    user_3 = create(:user, :verified, document_type: 1, document_number: "19066305H")
    user_4 = create(:user, :verified, document_type: 1, document_number: "78501386V")

    [user_2, user_3, user_4].each do |user|
      user.update!(email: nil)
    end

    expect(User.all.count).to eq 4
    expect(User.where(email: nil).count).to eq 3
    expect(User.where(document_type: nil).count).to eq 0
    expect(User.where(document_number: nil).count).to eq 0

    Rake.application.invoke_task("users:remove_users_data")

    user_1.reload
    expect(user_1.email).to eq "user@mail.com"
    expect(user_1.document_type).to eq "1"
    expect(user_1.document_number).to eq "12345678Z"

    [user_2, user_3, user_4].each do |user|
      user.reload
      expect(user.email).to eq nil
      expect(user.document_type).to eq nil
      expect(user.document_number).to eq nil
    end

    expect(User.all.count).to eq 4
    expect(User.where(email: nil).count).to eq 3
    expect(User.where(document_type: nil).count).to eq 3
    expect(User.where(document_number: nil).count).to eq 3
  end
end
