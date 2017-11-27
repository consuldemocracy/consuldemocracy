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

end
