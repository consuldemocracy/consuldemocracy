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
  end
end
