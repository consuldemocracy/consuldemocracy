require "rails_helper"

describe SDG::Phase do
  let(:phase) { build(:sdg_phase) }
  before { SDG::Phase["sensitization"].destroy }

  it "is valid with a valid kind" do
    phase.kind = "sensitization"

    expect(phase).to be_valid
  end

  it "is not valid without a kind" do
    phase.kind = nil

    expect(phase).not_to be_valid
  end

  it "is not valid with a duplicate kind" do
    phase.kind = "planning"

    expect(phase).not_to be_valid
  end

  it "is not valid with a custom kind" do
    expect { phase.kind = "improvement" }.to raise_exception(ArgumentError)
  end

  describe ".[]" do
    it "finds existing phases by kind" do
      expect(SDG::Phase["monitoring"].kind).to eq "monitoring"
    end

    it "raises an exception on empty databases" do
      SDG::Phase["monitoring"].destroy!

      expect { SDG::Phase["monitoring"] }.to raise_exception ActiveRecord::RecordNotFound
    end

    it "raises an exception for non-existing kinds" do
      expect { SDG::Phase["improvement"] }.to raise_exception ActiveRecord::StatementInvalid
    end
  end
end
