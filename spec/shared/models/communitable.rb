shared_examples "communitable" do

  let(:communitable) { create(model_name(described_class)) }
  let(:community) { communitable.community }

  describe "#associate_community" do
    it "creates the community" do
      expect(community.new_record?).to be false
    end

    it "makes the polymorphic association work automatically" do
      expect(community.communitable).to eq communitable
    end

    it "assigns the community id to the communitable object" do
      expect(communitable.community_id).to eq community.id
    end

    it "assigns the communitable id to the community" do
      expect(community.communitable_id).to eq communitable.id
    end

    it "assigns the communitable type to the community" do
      expect(community.communitable_type).to eq communitable.class.name
    end
  end

end
