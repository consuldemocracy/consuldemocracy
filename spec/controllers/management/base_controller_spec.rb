require "rails_helper"

describe Management::BaseController do

  describe "managed_user" do

    it "returns existent user with session document info if present" do
      session[:document_type] = "1"
      session[:document_number] = "333333333E"
      user = create(:user, :level_two, document_number: "333333333E")
      managed_user = subject.send(:managed_user)

      expect(managed_user).to eq user
    end

    it "returns new user if no user have the session document info" do
      session[:document_type] = "1"
      session[:document_number] = "333333333E"
      managed_user = subject.send(:managed_user)

      expect(managed_user).to be_new_record
      expect(managed_user.document_type).to eq "1"
      expect(managed_user.document_number).to eq "333333333E"
    end
  end

end