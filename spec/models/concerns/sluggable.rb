require 'spec_helper'

shared_examples_for 'sluggable' do

  describe 'generate_slug' do
    before do
      create(described_class.name.parameterize.tr('-', '_').to_sym, name: "Marlo Brañido Carlo")
    end

    context "when a new sluggable is created" do
      it "gets a slug string" do
        expect(described_class.last.slug).to eq("marlo-branido-carlo")
      end
    end

    context "when a sluggable is updated" do
      it "updates the slug with the new name" do
        described_class.last.update(name: "New name")
        expect(described_class.last.slug).to eq('new-name')
      end

      it "doesn't update the custom slug with new name" do
        described_class.last.update(slug: "custom-slug")
        expect(described_class.last.slug).to eq('custom-slug')

        described_class.last.update(name: "Another new name")
        expect(described_class.last.slug).to eq('custom-slug')
      end
    end
  end
end
