shared_examples "map validations" do

  let(:mappable) { build(model_name(described_class)) }

  describe "validations" do

    before do
      Setting["feature.map"] = true
    end

    after do
     Setting["feature.map"] = nil
    end

    it "is valid with a map location" do
     mappable.map_location = build(:map_location)
     mappable.skip_map = nil

     expect(mappable).to be_valid
    end

    it "is valid accepting that the mappable has no map" do
     mappable.skip_map = "1"
     mappable.map_location = nil

     expect(mappable).to be_valid
    end

    it "is valid when the feature map is deactivated" do
     Setting["feature.map"] = nil

     mappable.map_location = nil
     mappable.skip_map = nil

     expect(mappable).to be_valid
    end

    it "is not valid without a map location" do
     mappable.map_location = nil
     mappable.skip_map = nil

     expect(mappable).not_to be_valid
    end

    it "is not valid without accepting that the mappable has no map" do
     mappable.skip_map = nil

     expect(mappable).not_to be_valid
    end

  end

  describe "cache" do

    it "expires cache when the map is updated" do
      map_location = create(:map_location)
      mappable.map_location = map_location
      mappable.save

      expect { map_location.update(latitude: 12.34) }
        .to change { mappable.reload.updated_at }
    end

  end

end
