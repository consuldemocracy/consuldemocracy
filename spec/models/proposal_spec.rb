require 'rails_helper'

describe Proposal do
  let(:proposal) { build(:proposal) }

  it "should be valid" do
    expect(proposal).to be_valid
  end

  it "should not be valid without an author" do
    proposal.author = nil
    expect(proposal).to_not be_valid
  end

  it "should not be valid without a summary" do
    proposal.summary = nil
    expect(proposal).to_not be_valid
  end

  describe "#title" do
    it "should not be valid without a title" do
      proposal.title = nil
      expect(proposal).to_not be_valid
    end

    it "should not be valid when very short" do
      proposal.title = "abc"
      expect(proposal).to_not be_valid
    end

    it "should not be valid when very long" do
      proposal.title = "a" * 81
      expect(proposal).to_not be_valid
    end
  end

  describe "#description" do
    it "should be sanitized" do
      proposal.description = "<script>alert('danger');</script>"
      proposal.valid?
      expect(proposal.description).to eq("alert('danger');")
    end

    it "should not be valid when very long" do
      proposal.description = "a" * 6001
      expect(proposal).to_not be_valid
    end
  end

  describe "#question" do
    it "should not be valid without a question" do
      proposal.question = nil
      expect(proposal).to_not be_valid
    end

    it "should not be valid when very short" do
      proposal.question = "abc"
      expect(proposal).to_not be_valid
    end

    it "should not be valid when very long" do
      proposal.question = "a" * 141
      expect(proposal).to_not be_valid
    end
  end

  describe "#responsible_name" do
    it "should be mandatory" do
      proposal.responsible_name = nil
      expect(proposal).to_not be_valid
    end

    it "should not be valid when very short" do
      proposal.responsible_name = "abc"
      expect(proposal).to_not be_valid
    end

    it "should not be valid when very long" do
      proposal.responsible_name = "a" * 61
      expect(proposal).to_not be_valid
    end

    it "should be the document_number if level two user" do
      author = create(:user, :level_two, document_number: "12345678Z")
      proposal.author = author
      proposal.responsible_name = nil

      expect(proposal).to be_valid
      proposal.responsible_name = "12345678Z"
    end

     it "should be the document_number if level two user" do
      author = create(:user, :level_three, document_number: "12345678Z")
      proposal.author = author
      proposal.responsible_name = nil

      expect(proposal).to be_valid
      proposal.responsible_name = "12345678Z"
    end
  end

  describe "tag_list" do
    it "should sanitize the tag list" do
      proposal.tag_list = "user_id=1"
      proposal.valid?
      expect(proposal.tag_list).to eq(['user_id1'])
    end

    it "should not be valid with a tag list of more than 6 elements" do
      proposal.tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa", "Huelgas"]
      expect(proposal).to_not be_valid
    end

    it "should be valid with a tag list of more than 6 elements" do
      proposal.tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
      expect(proposal).to be_valid
    end
  end

  it "should not be valid without accepting terms of service" do
    proposal.terms_of_service = nil
    expect(proposal).to_not be_valid
  end

  it "should have a code" do
    Setting.find_by(key: "proposal_code_prefix").update(value: "TEST")
    proposal = create(:proposal)
    expect(proposal.code).to eq "TEST-#{proposal.created_at.strftime('%Y-%m')}-#{proposal.id}"
  end

  describe "#editable?" do
    let(:proposal) { create(:proposal) }
    before(:each) {Setting.find_by(key: "max_votes_for_proposal_edit").update(value: 5)}

    it "should be true if proposal has no votes yet" do
      expect(proposal.total_votes).to eq(0)
      expect(proposal.editable?).to be true
    end

    it "should be true if proposal has less than limit votes" do
      create_list(:vote, 4, votable: proposal)
      expect(proposal.total_votes).to eq(4)
      expect(proposal.editable?).to be true
    end

    it "should be false if proposal has more than limit votes" do
      create_list(:vote, 6, votable: proposal)
      expect(proposal.total_votes).to eq(6)
      expect(proposal.editable?).to be false
    end
  end

  describe "#votable_by?" do
    let(:proposal) { create(:proposal) }

    it "should be true for level two verified users" do
      user = create(:user, residence_verified_at: Time.now, confirmed_phone: "666333111")
      expect(proposal.votable_by?(user)).to be true
    end

    it "should be true for level three verified users" do
      user = create(:user, verified_at: Time.now)
      expect(proposal.votable_by?(user)).to be true
    end

    it "should be false for anonymous users" do
      user = create(:user)
      expect(proposal.votable_by?(user)).to be false
    end
  end

  describe "#register_vote" do
    let(:proposal) { create(:proposal) }

    describe "from level two verified users" do
      it "should register vote" do
        user = create(:user, residence_verified_at: Time.now, confirmed_phone: "666333111")
        expect {proposal.register_vote(user, 'yes')}.to change{proposal.reload.votes_for.size}.by(1)
      end
    end

    describe "from level three verified users" do
      it "should register vote" do
        user = create(:user, verified_at: Time.now)
        expect {proposal.register_vote(user, 'yes')}.to change{proposal.reload.votes_for.size}.by(1)
      end
    end

    describe "from anonymous users" do
      it "should not register vote" do
        user = create(:user)
        expect {proposal.register_vote(user, 'yes')}.to change{proposal.reload.votes_for.size}.by(0)
      end
    end
  end

  describe '#cached_votes_up' do

    describe "with deprecated long tag list" do

      it "should increase number of cached_total_votes" do
        proposal = create(:proposal)

        tag_list = ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7"]
        proposal.update_attribute(:tag_list, tag_list)

        expect(proposal.update_cached_votes).to eq(true)
      end

    end
  end

  describe '#hot_score' do
    let(:now) { Time.now }

    it "increases for newer proposals" do
      old = create(:proposal, :with_hot_score, created_at: now - 1.day)
      new = create(:proposal, :with_hot_score, created_at: now)
      expect(new.hot_score).to be > old.hot_score
    end

    it "increases for proposals with more comments" do
      more_comments = create(:proposal, :with_hot_score, created_at: now, comments_count: 25)
      less_comments = create(:proposal, :with_hot_score, created_at: now, comments_count: 1)
      expect(more_comments.hot_score).to be > less_comments.hot_score
    end

    it "increases for proposals with more positive votes" do
      more_likes = create(:proposal, :with_hot_score, created_at: now, cached_votes_up: 5)
      less_likes = create(:proposal, :with_hot_score, created_at: now, cached_votes_up: 1)
      expect(more_likes.hot_score).to be > less_likes.hot_score
    end

    it "increases for proposals with more confidence" do
      more_confidence = create(:proposal, :with_hot_score, created_at: now, cached_votes_up: 700)
      less_confidence = create(:proposal, :with_hot_score, created_at: now, cached_votes_up: 9)
      expect(more_confidence.hot_score).to be > less_confidence.hot_score
    end

    it "decays in older proposals, even if they have more votes" do
      older_more_voted = create(:proposal, :with_hot_score, created_at: now - 2.days, cached_votes_up: 900)
      new_less_voted   = create(:proposal, :with_hot_score, created_at: now, cached_votes_up: 9)
      expect(new_less_voted.hot_score).to be > older_more_voted.hot_score
    end

    describe 'actions which affect it' do
      let(:proposal) { create(:proposal, :with_hot_score) }

      it "increases with votes" do
        previous = proposal.hot_score
        5.times { proposal.register_vote(create(:user, verified_at: Time.now), true) }
        expect(previous).to be < proposal.reload.hot_score
      end

      it "increases with comments" do
        previous = proposal.hot_score
        25.times{ Comment.create(user: create(:user), commentable: proposal, body: 'foobarbaz') }
        expect(previous).to be < proposal.reload.hot_score
      end
    end
  end

  describe "custom tag counters when hiding/restoring" do
    it "decreases the tag counter when hiden, and increases it when restored" do
      proposal = create(:proposal, tag_list: "foo")
      tag = ActsAsTaggableOn::Tag.where(name: 'foo').first
      expect(tag.proposals_count).to eq(1)

      proposal.hide
      expect(tag.reload.proposals_count).to eq(0)

      proposal.restore
      expect(tag.reload.proposals_count).to eq(1)
    end
  end

  describe "#confidence_score" do

    it "takes into account votes" do
      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 100)
      expect(proposal.confidence_score).to eq(10000)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 0)
      expect(proposal.confidence_score).to eq(0)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 75)
      expect(proposal.confidence_score).to eq(7500)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 750)
      expect(proposal.confidence_score).to eq(75000)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 10)
      expect(proposal.confidence_score).to eq(1000)
    end

    describe 'actions which affect it' do
      let(:proposal) { create(:proposal, :with_confidence_score) }

      it "increases with like" do
        previous = proposal.confidence_score
        5.times { proposal.register_vote(create(:user, verified_at: Time.now), true) }
        expect(previous).to be < proposal.confidence_score
      end
    end

  end
end
