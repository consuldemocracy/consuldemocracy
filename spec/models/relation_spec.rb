require 'rails_helper'

describe RelatedContent do

  let(:parent_relationable) { create([:proposal, :debate, :budget_investment].sample) }
  let(:child_relationable) { create([:proposal, :debate, :budget_investment].sample) }

  it "should allow relationables from various classes" do
    expect(build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)).to be_valid
    expect(build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)).to be_valid
    expect(build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)).to be_valid
  end

  it "should not allow empty relationables" do
    expect(build(:related_content)).not_to be_valid
    expect(build(:related_content, parent_relationable: parent_relationable)).not_to be_valid
    expect(build(:related_content, child_relationable: child_relationable)).not_to be_valid
  end

  it "should not allow repeated related contents" do
    related_content = create(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)
    new_related_content = build(:related_content, parent_relationable: related_content.parent_relationable, child_relationable: related_content.child_relationable)
    expect(new_related_content).not_to be_valid
  end

  describe 'create_opposite_related_content' do
    let(:parent_relationable) { create(:proposal) }
    let(:child_relationable) { create(:debate) }
    let(:related_content) { build(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable) }

    it 'creates an opposite related_content' do
      expect { related_content.save }.to change { RelatedContent.count }.by(2)
      expect(related_content.opposite_related_content.child_relationable_id).to eq(parent_relationable.id)
      expect(related_content.opposite_related_content.child_relationable_type).to eq(parent_relationable.class.name)
      expect(related_content.opposite_related_content.parent_relationable_id).to eq(child_relationable.id)
      expect(related_content.opposite_related_content.parent_relationable_type).to eq(child_relationable.class.name)
      expect(related_content.opposite_related_content.opposite_related_content.id).to eq(related_content.id)
    end
  end

  describe 'relationable destroy' do
    let(:parent_relationable) { create(:proposal) }
    let(:child_relationable) { create(:debate) }

    it 'destroys both related contents involved' do
      related_content = create(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)
      expect { related_content.parent_relationable.destroy }.to change { RelatedContent.all.count }.by(-2)
      expect(child_relationable.related_contents).to be_empty
    end
  end

  # TODO: Move this into a Relationable shared context
  describe '#report_related_content' do
    it 'increments both relation and opposite relation times_reported counters' do
      related_content = create(:related_content, parent_relationable: parent_relationable, child_relationable: child_relationable)
      parent_relationable.report_related_content(child_relationable)

      expect(related_content.reload.times_reported).to eq(1)
      expect(related_content.reload.opposite_related_content.times_reported).to eq(1)
    end
  end

end
