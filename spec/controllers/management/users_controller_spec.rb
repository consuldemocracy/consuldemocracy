require "rails_helper"

describe Management::UsersController do
  describe "logout" do
    it "removes user data from the session" do
      manager = create(:manager)
      sign_in(manager.user)
      session[:document_type] = "1"
      session[:document_number] = "12345678Z"

      get :logout

      expect(session[:document_type]).to be nil
      expect(session[:document_number]).to be nil
      expect(controller.send(:current_manager)).to eq manager.user
      expect(response).to redirect_to management_root_path
    end
  end

  describe "POST create" do
    before { sign_in(create(:manager).user) }

    it "creates a new user when passing valid data" do
      expect do
        post :create, params: {
          user: {
            document_type: "1",
            document_number: "12345678A",
            username: "newuser",
            email: "newuser@consul.dev",
            date_of_birth: 20.years.from_now.to_date
          }
        }
      end.to change { User.count }.by(1)

      expect(response).to be_successful
    end

    it "does not create a new user when passing invalid data" do
      expect do
        post :create, params: {
          user: {
            document_type: "1",
            document_number: "12345678A",
            username: "",
            email: "newuser@consul.dev",
            date_of_birth: 20.years.from_now.to_date
          }
        }
      end.not_to change { User.count }

      expect(response).to be_successful
    end

    it "creates a new user when an erased one existed" do
      erased_user = create(:user, :level_two, erased_at: 1.month.ago)

      expect do
        post :create, params: {
          user: {
            document_type: erased_user.document_type,
            document_number: erased_user.document_number,
            username: "newuser",
            email: "newuser@consul.dev",
            date_of_birth: 20.years.from_now.to_date
          }
        }
      end.to change { User.count }.by(1)
    end

    it "takes votes from an erased user" do
      erased_user = create(:user, :level_two, erased_at: 1.month.ago)
      vote = create(:vote, voter: erased_user)

      post :create, params: {
        user: {
          document_type: erased_user.document_type,
          document_number: erased_user.document_number,
          username: "newuser",
          email: "newuser@consul.dev",
          date_of_birth: 20.years.from_now.to_date
        }
      }

      expect(response).to be_successful
      expect(vote.reload.voter.email).to eq "newuser@consul.dev"
    end

    it "does not take votes from an erased user if there are validation errors" do
      erased_user = create(:user, :level_two, erased_at: 1.month.ago)
      vote = create(:vote, voter: erased_user)
      allow_any_instance_of(User).to receive(:save).and_return(false)

      post :create, params: {
        user: {
          document_number: erased_user.document_number,
          document_type: erased_user.document_type,
          username: "newuser",
          email: "newuser@consul.dev",
          date_of_birth: 20.years.from_now.to_date
        }
      }

      expect(response).to be_successful
      expect(vote.reload.voter).to eq erased_user
    end
  end
end
