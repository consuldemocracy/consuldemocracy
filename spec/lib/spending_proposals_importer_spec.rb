require 'rails_helper'

describe SpendingProposalsImporter do

  let(:importer) { SpendingProposalsImporter.new }

  describe '#import' do
    it "Imports a city spending proposal" do
      sp = create(:spending_proposal)

      expect { importer.import(sp) }.to change{ Budget::Investment.count }.from(0).to(1)

      inv = Budget::Investment.last

      expect(inv.author).to eq(sp.author)
      expect(inv.title).to eq(sp.title)
      expect(inv.heading.name).to eq("Toda la ciudad")
      expect(inv.heading.group.name).to eq("Toda la ciudad")
    end

    it "Imports a city spending proposal" do
      sp = create(:spending_proposal, geozone: create(:geozone, name: "Bel Air"))

      expect { importer.import(sp) }.to change{ Budget::Investment.count }.from(0).to(1)

      inv = Budget::Investment.last

      expect(inv.author).to eq(sp.author)
      expect(inv.title).to eq(sp.title)
      expect(inv.heading.name).to eq("Bel Air")
      expect(inv.heading.group.name).to eq("Barrios")
    end

    it "Uses existing budgets, headings and groups instead of creating new ones" do
      sp1 = create(:spending_proposal, geozone: create(:geozone, name: "Bel Air"))
      sp2 = create(:spending_proposal, geozone: create(:geozone, name: "Bel Air"))

      expect { importer.import(sp1) }.to change{ Budget::Investment.count }.from(0).to(1)
      expect { importer.import(sp2) }.to change{ Budget::Investment.count }.from(1).to(2)

      inv1 = Budget::Investment.first
      inv2 = Budget::Investment.last

      expect(inv2.heading).to eq(inv1.heading)
    end

    it "Imports feasibility correctly" do
      sp = create(:spending_proposal)
      feasible = create(:spending_proposal, feasible: true)
      unfeasible = create(:spending_proposal, feasible: false)

      expect(importer.import(sp).feasibility).to eq('undecided')
      expect(importer.import(feasible).feasibility).to eq('feasible')
      expect(importer.import(unfeasible).feasibility).to eq('unfeasible')
    end
  end
end
