shared_examples "map validations" do

	let(:mappable) { build(model_name(described_class)) }

	describe "map" do

		before(:each) do
			Setting["feature.map"] = true
		end

		after(:each) do
			Setting["feature.map"] = nil
		end

		it "should be valid with a map location" do
			mappable.map_location = build(:map_location)
			mappable.skip_map = nil

			expect(mappable).to be_valid
		end

		it "should be valid accepting that the mappable has no map" do
			mappable.skip_map = "1"
			mappable.map_location = nil

			expect(mappable).to be_valid
		end

		it "should be valid when the feature map is deactivated" do
			Setting["feature.map"] = nil

			mappable.map_location = nil
			mappable.skip_map = nil

			expect(mappable).to be_valid
		end

		it "should not be valid without a map location" do
			mappable.map_location = nil
			mappable.skip_map = nil

			expect(mappable).to_not be_valid
		end

		it "should not be valid without accepting that the mappable has no map" do
			mappable.skip_map = nil

			expect(mappable).to_not be_valid
		end

	end

end