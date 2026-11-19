require "rails_helper"

RSpec.describe Identity do
  let(:identity) { build(:identity) }

  it "is valid" do
    expect(identity).to be_valid
  end

  describe ".first_or_create_from_oauth" do
    let(:auth) { OmniAuth::AuthHash.new(provider: "twitter", uid: "12345") }

    it "does not create two identities when calling the method twice at the same time", :race_condition do
      with_sleep_after_validations(Identity) do
        2.times.map do
          Thread.new { Identity.first_or_create_from_oauth(auth) }
        end.each(&:join)

        expect(Identity.where(provider: "twitter", uid: "12345").count).to eq 1
      end
    end
  end
end
