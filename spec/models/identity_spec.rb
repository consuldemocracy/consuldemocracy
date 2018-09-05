require 'rails_helper'

RSpec.describe Identity, type: :model do
  let(:identity) { build(:identity) }

  it "is not valid without a provider" do
    identity.provider = nil
    expect(identity).not_to be_valid
  end

  it "is not valid without an uid" do
    identity.uid = nil
    expect(identity).not_to be_valid
  end

  describe "#first_or_create_from_oauth" do
    let(:auth) do
      OpenStruct.new(uid: 'string', provider: 'Provider')
    end

    it "does not create an Identity if one already exists" do
      identity = create(:identity, uid: 'string', provider: 'Provider')

      expect{Identity.first_or_create_from_oauth(auth)}.to change { Identity.count }.by(0)
    end

    it "returns the first matching identity" do
      first_identity = create(:identity, uid: 'string', provider: 'Provider')

      expect(Identity.first_or_create_from_oauth(auth)).to eq(first_identity)
    end

    it "creates a new Identity if none exists" do
      expect{Identity.first_or_create_from_oauth(auth)}.to change { Identity.count }.by(1)
    end

    it "returns a new Identity if none exists" do
      expect(Identity.first_or_create_from_oauth(auth).uid).to eq('string')
      expect(Identity.first_or_create_from_oauth(auth).provider).to eq('Provider')
    end
  end

end
