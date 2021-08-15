shared_examples "map validations" do
  let(:mappable) { build(model_name(described_class)) }

  describe "validations" do
    before do
      Setting["feature.map"] = true
    end

    it "is valid with a map location" do
      mappable.map_location = build(:map_location)

      expect(mappable).to be_valid
    end

    it "is valid without a location" do
      mappable.map_location = nil

      expect(mappable).to be_valid
    end

    it "is valid when the feature map is deactivated" do
      Setting["feature.map"] = nil

      mappable.map_location = nil

      expect(mappable).to be_valid
    end
  end

  describe "cache" do
    it "expires cache when the map is updated" do
      map_location = create(:map_location)
      mappable.map_location = map_location
      mappable.save!

      expect { map_location.update(latitude: 12.34) }
        .to change { mappable.reload.cache_version }
    end
  end
end
