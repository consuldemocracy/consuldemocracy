require 'rails_helper'

describe Debate do
  let(:debate) { build(:debate) }

  it "should be valid" do
    expect(debate).to be_valid
  end

  it "should not be valid without an author" do
    debate.author = nil
    expect(debate).to_not be_valid
  end

  it "should not be valid without a title" do
    debate.title = nil
    expect(debate).to_not be_valid
  end

  describe "#description" do
    it "should be mandatory" do
      debate.description = nil
      expect(debate).to_not be_valid
    end

    it "should be sanitized" do
      debate.description = "<script>alert('danger');</script>"
      debate.valid?
      expect(debate.description).to eq("alert('danger');")
    end

    it "should be html_safe" do
      debate.description = "<script>alert('danger');</script>"
      expect(debate.description).to be_html_safe
    end
  end

  it "should sanitize the tag list" do
    debate.tag_list = "user_id=1"
    debate.valid?
    expect(debate.tag_list).to eq(['user_id1'])
  end

  it "should not be valid without accepting terms of service" do
    debate.terms_of_service = nil
    expect(debate).to_not be_valid
  end

  describe "#editable?" do
    let(:debate) { create(:debate) }

    it "should be true if debate has no votes yet" do
      expect(debate.total_votes).to eq(0)
      expect(debate.editable?).to be true
    end

    it "should be false if debate has votes" do
      create(:vote, votable: debate)
      expect(debate.total_votes).to eq(1)
      expect(debate.editable?).to be false
    end
  end

  describe "#editable_by?" do
    let(:debate) { create(:debate) }

    it "should be true if user is the author and debate is editable" do
      expect(debate.editable_by?(debate.author)).to be true
    end

    it "should be false if debate is not editable" do
      create(:vote, votable: debate)
      expect(debate.editable_by?(debate.author)).to be false
    end

    it "should be false if user is not the author" do
      expect(debate.editable_by?(create(:user))).to be false
    end
  end

  describe "#register_vote" do
    let(:debate) { create(:debate) }

    before(:each) do
      Setting.find_by(key: "max_ratio_anon_votes_on_debates").update(value: 50)
    end

    describe "from level two verified users" do
      it "should register vote" do
        user = create(:user, residence_verified_at: Time.now, confirmed_phone: "666333111")
        expect {debate.register_vote(user, 'yes')}.to change{debate.reload.votes_for.size}.by(1)
      end

      it "should not increase anonymous votes counter " do
        user = create(:user, residence_verified_at: Time.now, confirmed_phone: "666333111")
        expect {debate.register_vote(user, 'yes')}.to_not change{debate.reload.cached_anonymous_votes_total}
      end
    end

    describe "from level three verified users" do
      it "should register vote" do
        user = create(:user, verified_at: Time.now)
        expect {debate.register_vote(user, 'yes')}.to change{debate.reload.votes_for.size}.by(1)
      end

      it "should not increase anonymous votes counter " do
        user = create(:user, verified_at: Time.now)
        expect {debate.register_vote(user, 'yes')}.to_not change{debate.reload.cached_anonymous_votes_total}
      end
    end

    describe "from anonymous users when anonymous votes are allowed" do
      before(:each) {debate.update(cached_anonymous_votes_total: 42, cached_votes_total: 100)}

      it "should register vote " do
        user = create(:user)
        expect {debate.register_vote(user, 'yes')}.to change {debate.reload.votes_for.size}.by(1)
      end

      it "should increase anonymous votes counter " do
        user = create(:user)
        expect {debate.register_vote(user, 'yes')}.to change {debate.reload.cached_anonymous_votes_total}.by(1)
      end
    end

    describe "from anonymous users when there are too many anonymous votes" do
      before(:each) {debate.update(cached_anonymous_votes_total: 520, cached_votes_total: 1000)}

      it "should not register vote " do
        user = create(:user)
        expect {debate.register_vote(user, 'yes')}.to_not change {debate.reload.votes_for.size}
      end

      it "should not increase anonymous votes counter " do
        user = create(:user)
        expect {debate.register_vote(user, 'yes')}.to_not change {debate.reload.cached_anonymous_votes_total}
      end
    end
  end

  describe "#votable_by?" do
    let(:debate) { create(:debate) }

    before(:each) do
      Setting.find_by(key: "max_ratio_anon_votes_on_debates").update(value: 50)
    end

    it "should be true for level two verified users" do
      user = create(:user, residence_verified_at: Time.now, confirmed_phone: "666333111")
      expect(debate.votable_by?(user)).to be true
    end

    it "should be true for level three verified users" do
      user = create(:user, verified_at: Time.now)
      expect(debate.votable_by?(user)).to be true
    end

    it "should be true for anonymous users if allowed anonymous votes" do
      debate.update(cached_anonymous_votes_total: 420, cached_votes_total: 1000)
      user = create(:user)
      expect(debate.votable_by?(user)).to be true
    end

    it "should be true for anonymous users if less than 100 votes" do
      debate.update(cached_anonymous_votes_total: 90, cached_votes_total: 92)
      user = create(:user)
      expect(debate.votable_by?(user)).to be true
    end

    it "should be false for anonymous users if too many anonymous votes" do
      debate.update(cached_anonymous_votes_total: 520, cached_votes_total: 1000)
      user = create(:user)
      expect(debate.votable_by?(user)).to be false
    end
  end

  describe '#anonymous_votes_ratio' do
    it "returns the percentage of anonymous votes of the total votes" do
      debate = create(:debate, cached_anonymous_votes_total: 25, cached_votes_total: 100)
      expect(debate.anonymous_votes_ratio).to eq(25.0)
    end
  end

end
