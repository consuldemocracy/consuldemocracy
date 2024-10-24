require "rails_helper"

describe RelatedContentScore do
  it "is valid" do
    expect(build(:related_content_score)).to be_valid
  end

  it "is not valid with empty user or empty related_content" do
    expect(build(:related_content_score, user: nil)).not_to be_valid
    expect(build(:related_content_score, related_content: nil)).not_to be_valid
  end

  it "is not valid with repeated related content scores" do
    user = create(:user)
    related_content = build(:related_content)

    create(:related_content_score, related_content: related_content, user: user)

    new_score = build(:related_content_score, related_content: related_content, user: user)

    expect(new_score).not_to be_valid
  end
end
