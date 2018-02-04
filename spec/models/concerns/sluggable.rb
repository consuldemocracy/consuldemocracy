require 'spec_helper'

shared_examples_for 'sluggable' do

  describe 'generate_slug' do
    let(:factory_name) { described_class.name.parameterize('_').to_sym }
    let(:sluggable) { create(factory_name, name: "Marló Brañido Carlo") }

    context "when a new sluggable is created" do
      it "gets a slug string" do
        expect(sluggable.slug).to eq("marlo-branido-carlo")
      end
    end
  end
end
