require "rails_helper"

describe SkipValidation do
  describe ".skip_validation" do
    before do
      dummy_model = Class.new do
        include ActiveModel::Model
        include SkipValidation
        attr_accessor :title, :description

        validates :title, presence: true, length: { in: 10..60, allow_nil: true }
        validates :description, presence: true
      end

      stub_const("DummyModel", dummy_model)
    end

    it "accepts validator classes as parameters" do
      DummyModel.skip_validation :title, ActiveModel::Validations::PresenceValidator

      expect(DummyModel.new(title: nil, description: "Something")).to be_valid
    end

    it "accepts symbols as parameters" do
      DummyModel.skip_validation :title, :presence

      expect(DummyModel.new(title: nil, description: "Something")).to be_valid
    end

    it "does not affect other attributes" do
      DummyModel.skip_validation :title, :presence

      expect(DummyModel.new(title: nil, description: nil)).not_to be_valid
    end

    it "does not affect other validations" do
      DummyModel.skip_validation :title, :presence

      expect(DummyModel.new(title: "Short", description: "Something")).not_to be_valid
    end

    it "works with validators other than presence" do
      DummyModel.skip_validation :title, :length

      expect(DummyModel.new(title: "Short", description: "Something")).to be_valid
      expect(DummyModel.new(title: nil, description: "Something")).not_to be_valid
    end
  end

  describe ".skip_translation_validation" do
    before do
      dummy_banner = Class.new(ApplicationRecord) do
        def self.name
          "DummyBanner"
        end
        self.table_name = "banners"

        translates :title, touch: true
        translates :description, touch: true
        include Globalizable

        validates_translation :title, presence: true
        validates_translation :description, presence: true
      end

      stub_const("DummyBanner", dummy_banner)
    end

    it "removes the validation from the translatable attribute" do
      DummyBanner.skip_translation_validation :title, :presence

      custom_banner = DummyBanner.new(build(:banner).attributes.merge(title: nil))

      expect { custom_banner.save! }.not_to raise_exception
    end

    it "does not affect other validations" do
      DummyBanner.skip_translation_validation :title, :presence

      custom_banner = DummyBanner.new(build(:banner).attributes.merge(description: nil))

      expect { custom_banner.save! }.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
