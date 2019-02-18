require "spec_helper"

shared_examples_for "sluggable" do |updatable_slug_trait:|

  describe "generate_slug" do
    let(:factory_name) { described_class.name.parameterize("_").to_sym }
    let(:sluggable) { create(factory_name, name: "Marló Brañido Carlo") }

    context "when a new sluggable is created" do
      it "gets a slug string" do
        expect(sluggable.slug).to eq("marlo-branido-carlo")
      end
    end

    context "slug updating condition is true" do
      it "slug is updated" do
        updatable = create(factory_name, updatable_slug_trait, name: "Old Name")
        expect{updatable.update_attributes(name: "New Name")}
          .to change{ updatable.slug }.from("old-name").to("new-name")
      end
    end

    context "slug updating condition is false" do
      it "slug isn't updated" do
        expect{sluggable.update_attributes(name: "New Name")}
          .not_to (change{ sluggable.slug })
      end
    end
  end
end
