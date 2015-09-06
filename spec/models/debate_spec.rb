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

  describe '#hot_score' do
    let(:now) { Time.now }

    it "increases for newer debates" do
      old = create(:debate, :with_hot_score, created_at: now - 1.day)
      new = create(:debate, :with_hot_score, created_at: now)
      expect(new.hot_score).to be > old.hot_score
    end

    it "increases for debates with more comments" do
      more_comments = create(:debate, :with_hot_score, created_at: now, comments_count: 10)
      less_comments = create(:debate, :with_hot_score, created_at: now, comments_count: 1)
      expect(more_comments.hot_score).to be > less_comments.hot_score
    end

    it "increases for debates with more positive votes" do
      more_likes = create(:debate, :with_hot_score, created_at: now, cached_votes_total: 10, cached_votes_up: 5)
      less_likes = create(:debate, :with_hot_score, created_at: now, cached_votes_total: 10, cached_votes_up: 1)
      expect(more_likes.hot_score).to be > less_likes.hot_score
    end

    it "increases for debates with more confidence" do
      more_confidence = create(:debate, :with_hot_score, created_at: now, cached_votes_total: 1000, cached_votes_up: 700)
      less_confidence = create(:debate, :with_hot_score, created_at: now, cached_votes_total: 10, cached_votes_up: 9)
      expect(more_confidence.hot_score).to be > less_confidence.hot_score
    end

    it "decays in older debates, even if they have more votes" do
      older_more_voted = create(:debate, :with_hot_score, created_at: now - 2.days, cached_votes_total: 1000, cached_votes_up: 900)
      new_less_voted   = create(:debate, :with_hot_score, created_at: now, cached_votes_total: 10, cached_votes_up: 9)
      expect(new_less_voted.hot_score).to be > older_more_voted.hot_score
    end

    describe 'actions which affect it' do
      let(:debate) { create(:debate, :with_hot_score) }

      it "increases with likes" do
        previous = debate.hot_score
        5.times { debate.register_vote(create(:user), true) }
        expect(previous).to be < debate.hot_score
      end

      it "decreases with dislikes" do
        debate.register_vote(create(:user), true)
        previous = debate.hot_score
        3.times { debate.register_vote(create(:user), false) }
        expect(previous).to be > debate.hot_score
      end

      it "increases with comments" do
        previous = debate.hot_score
        Comment.create(user: create(:user), commentable: debate, body: 'foo')
        expect(previous).to be < debate.hot_score
      end
    end

  end

  describe "self.search" do
    it "find debates by title" do
      debate1 = create(:debate, title: "Karpov vs Kasparov")
      create(:debate, title: "Bird vs Magic")
      search = Debate.search("Kasparov")
      expect(search.size).to eq(1)
      expect(search.first).to eq(debate1)
    end

    it "find debates by description" do
      debate1 = create(:debate, description: "...chess masters...")
      create(:debate, description: "...basket masters...")
      search = Debate.search("chess")
      expect(search.size).to eq(1)
      expect(search.first).to eq(debate1)
    end

    it "find debates by title and description" do
      create(:debate, title: "Karpov vs Kasparov", description: "...played like Gauss...")
      create(:debate, title: "Euler vs Gauss", description: "...math masters...")
      search = Debate.search("Gauss")
      expect(search.size).to eq(2)
    end

    it "returns no results if no search term provided" do
      expect(Debate.search("    ").size).to eq(0)
    end
  end

  describe "cache" do
    let(:debate) { create(:debate) }

    it "should expire cache when it has a new comment" do
      expect { create(:comment, commentable: debate) }
      .to change { debate.updated_at }
    end

    it "should expire cache when it has a new vote" do
      expect { create(:vote, votable: debate) }
      .to change { debate.updated_at }
    end

    it "should expire cache when it has a new tag" do
      expect { debate.update(tag_list: "new tag") }
      .to change { debate.updated_at }
    end

    it "should expire cache when hidden" do
      expect { debate.hide }
      .to change { debate.updated_at }
    end

    it "should expire cache when the author is hidden" do
      expect { debate.author.hide }
      .to change { [debate.reload.updated_at, debate.author.updated_at] }
    end

    it "should expire cache when its author changes" do
      expect { debate.author.update(username: "Eva") }
      .to change { [debate.reload.updated_at, debate.author.updated_at] }
    end

    it "should expire cache when the author's organization get verified" do
      create(:organization, user: debate.author)
      expect { debate.author.organization.verify }
      .to change { [debate.reload.updated_at, debate.author.updated_at] }
    end
  end

end