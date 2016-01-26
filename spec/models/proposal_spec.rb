# coding: utf-8
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

    it "should not be updated when the author is deleted" do
      author = create(:user, :level_three, document_number: "12345678Z")
      proposal.author = author
      proposal.save

      proposal.author.erase

      proposal.save
      expect(proposal.responsible_name).to eq "12345678Z"
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
    Setting["proposal_code_prefix"] = "TEST"
    proposal = create(:proposal)
    expect(proposal.code).to eq "TEST-#{proposal.created_at.strftime('%Y-%m')}-#{proposal.id}"
  end

  describe "#editable?" do
    let(:proposal) { create(:proposal) }
    before(:each) {Setting["max_votes_for_proposal_edit"] = 5}

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
      older_more_voted = create(:proposal, :with_hot_score, created_at: now - 5.days, cached_votes_up: 900)
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
      expect(proposal.confidence_score).to eq(1)

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

  describe "cache" do
    let(:proposal) { create(:proposal) }

    it "should expire cache when it has a new comment" do
      expect { create(:comment, commentable: proposal) }
      .to change { proposal.updated_at }
    end

    it "should expire cache when it has a new vote" do
      expect { create(:vote, votable: proposal) }
      .to change { proposal.updated_at }
    end

    it "should expire cache when it has a new flag" do
      expect { create(:flag, flaggable: proposal) }
      .to change { proposal.reload.updated_at }
    end

    it "should expire cache when it has a new tag" do
      expect { proposal.update(tag_list: "new tag") }
      .to change { proposal.updated_at }
    end

    it "should expire cache when hidden" do
      expect { proposal.hide }
      .to change { proposal.updated_at }
    end

    it "should expire cache when the author is hidden" do
      expect { proposal.author.hide }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end

    it "should expire cache when the author is erased" do
      expect { proposal.author.erase }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end

    it "should expire cache when its author changes" do
      expect { proposal.author.update(username: "Eva") }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end

    it "should expire cache when the author's organization get verified" do
      create(:organization, user: proposal.author)
      expect { proposal.author.organization.verify }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end
  end

  describe "search" do

    context "attributes" do

      it "searches by title" do
        proposal = create(:proposal, title: 'save the world')
        results = Proposal.search('save the world')
        expect(results).to eq([proposal])
      end

      it "searches by summary" do
        proposal = create(:proposal, summary: 'basically...')
        results = Proposal.search('basically')
        expect(results).to eq([proposal])
      end

      it "searches by description" do
        proposal = create(:proposal, description: 'in order to save the world one must think about...')
        results = Proposal.search('one must think')
        expect(results).to eq([proposal])
      end

      it "searches by question" do
        proposal = create(:proposal, question: 'to be or not to be')
        results = Proposal.search('to be or not to be')
        expect(results).to eq([proposal])
      end

      it "searches by author name" do
        author = create(:user, username: 'Danny Trejo')
        proposal = create(:proposal, author: author)
        results = Proposal.search('Danny')
        expect(results).to eq([proposal])
      end

      it "searches by geozone" do
        geozone = create(:geozone, name: 'California')
        proposal = create(:proposal, geozone: geozone)
        results = Proposal.search('California')
        expect(results).to eq([proposal])
      end

    end

    context "stemming" do

      it "searches word stems" do
        proposal = create(:proposal, summary: 'biblioteca')

        results = Proposal.search('bibliotecas')
        expect(results).to eq([proposal])

        results = Proposal.search('bibliotec')
        expect(results).to eq([proposal])

        results = Proposal.search('biblioteco')
        expect(results).to eq([proposal])
      end

    end

    context "accents" do

      it "searches with accents" do
        proposal = create(:proposal, summary: 'difusión')

        results = Proposal.search('difusion')
        expect(results).to eq([proposal])

        proposal2 = create(:proposal, summary: 'estadisticas')
        results = Proposal.search('estadísticas')
        expect(results).to eq([proposal2])
      end

    end

    context "case" do

      it "searches case insensite" do
        proposal = create(:proposal, title: 'SHOUT')

        results = Proposal.search('shout')
        expect(results).to eq([proposal])

        proposal2 = create(:proposal, title: "scream")
        results = Proposal.search("SCREAM")
        expect(results).to eq([proposal2])
      end

    end

    context "tags" do

      it "searches by tags" do
        proposal = create(:proposal, tag_list: 'Latina')

        results = Proposal.search('Latina')
        expect(results.first).to eq(proposal)
      end

    end

    context "order" do

      it "orders by weight" do
        proposal_question    = create(:proposal, question:    'stop corruption')
        proposal_title       = create(:proposal,  title:       'stop corruption')
        proposal_description = create(:proposal,  description: 'stop corruption')
        proposal_summary     = create(:proposal,  summary:     'stop corruption')

        results = Proposal.search('stop corruption')

        expect(results.first).to eq(proposal_title)
        expect(results.second).to eq(proposal_question)
        expect(results.third).to eq(proposal_summary)
        expect(results.fourth).to eq(proposal_description)
      end

      it "orders by weight and then by votes" do
        title_some_votes    = create(:proposal, title: 'stop corruption', cached_votes_up: 5)
        title_least_voted   = create(:proposal, title: 'stop corruption', cached_votes_up: 2)
        title_most_voted    = create(:proposal, title: 'stop corruption', cached_votes_up: 10)

        summary_most_voted  = create(:proposal, summary: 'stop corruption', cached_votes_up: 10)

        results = Proposal.search('stop corruption')

        expect(results.first).to eq(title_most_voted)
        expect(results.second).to eq(title_some_votes)
        expect(results.third).to eq(title_least_voted)
        expect(results.fourth).to eq(summary_most_voted)
      end

      it "gives much more weight to word matches than votes" do
        exact_title_few_votes    = create(:proposal, title: 'stop corruption', cached_votes_up: 5)
        similar_title_many_votes = create(:proposal, title: 'stop some of the corruption', cached_votes_up: 500)

        results = Proposal.search('stop corruption')

        expect(results.first).to eq(exact_title_few_votes)
        expect(results.second).to eq(similar_title_many_votes)
      end

    end

    context "reorder" do

      it "should be able to reorder by hot_score after searching" do
        lowest_score  = create(:proposal,  title: 'stop corruption', cached_votes_up: 1)
        highest_score = create(:proposal,  title: 'stop corruption', cached_votes_up: 2)
        average_score = create(:proposal,  title: 'stop corruption', cached_votes_up: 3)

        lowest_score.update_column(:hot_score, 1)
        highest_score.update_column(:hot_score, 100)
        average_score.update_column(:hot_score, 10)

        results = Proposal.search('stop corruption')

        expect(results.first).to eq(average_score)
        expect(results.second).to eq(highest_score)
        expect(results.third).to eq(lowest_score)

        results = results.sort_by_hot_score

        expect(results.first).to eq(highest_score)
        expect(results.second).to eq(average_score)
        expect(results.third).to eq(lowest_score)
      end

      it "should be able to reorder by confidence_score after searching" do
        lowest_score  = create(:proposal,  title: 'stop corruption', cached_votes_up: 1)
        highest_score = create(:proposal,  title: 'stop corruption', cached_votes_up: 2)
        average_score = create(:proposal,  title: 'stop corruption', cached_votes_up: 3)

        lowest_score.update_column(:confidence_score, 1)
        highest_score.update_column(:confidence_score, 100)
        average_score.update_column(:confidence_score, 10)

        results = Proposal.search('stop corruption')

        expect(results.first).to eq(average_score)
        expect(results.second).to eq(highest_score)
        expect(results.third).to eq(lowest_score)

        results = results.sort_by_confidence_score

        expect(results.first).to eq(highest_score)
        expect(results.second).to eq(average_score)
        expect(results.third).to eq(lowest_score)
      end

      it "should be able to reorder by created_at after searching" do
        recent  = create(:proposal,  title: 'stop corruption', cached_votes_up: 1, created_at: 1.week.ago)
        newest  = create(:proposal,  title: 'stop corruption', cached_votes_up: 2, created_at: Time.now)
        oldest  = create(:proposal,  title: 'stop corruption', cached_votes_up: 3, created_at: 1.month.ago)

        results = Proposal.search('stop corruption')

        expect(results.first).to eq(oldest)
        expect(results.second).to eq(newest)
        expect(results.third).to eq(recent)

        results = results.sort_by_created_at

        expect(results.first).to eq(newest)
        expect(results.second).to eq(recent)
        expect(results.third).to eq(oldest)
      end

      it "should be able to reorder by most commented after searching" do
        least_commented = create(:proposal,  title: 'stop corruption',  cached_votes_up: 1, comments_count: 1)
        most_commented  = create(:proposal,  title: 'stop corruption',  cached_votes_up: 2, comments_count: 100)
        some_comments   = create(:proposal,  title: 'stop corruption',  cached_votes_up: 3, comments_count: 10)

        results = Proposal.search('stop corruption')

        expect(results.first).to eq(some_comments)
        expect(results.second).to eq(most_commented)
        expect(results.third).to eq(least_commented)

        results = results.sort_by_most_commented

        expect(results.first).to eq(most_commented)
        expect(results.second).to eq(some_comments)
        expect(results.third).to eq(least_commented)
      end

    end

    context "no results" do

      it "no words match" do
        proposal = create(:proposal, title: 'save world')

        results = Proposal.search('destroy planet')
        expect(results).to eq([])
      end

      it "too many typos" do
        proposal = create(:proposal, title: 'fantastic')

        results = Proposal.search('frantac')
        expect(results).to eq([])
      end

      it "too much stemming" do
        proposal = create(:proposal, title: 'reloj')

        results = Proposal.search('superrelojimetro')
        expect(results).to eq([])
      end

      it "empty" do
        proposal = create(:proposal, title: 'great')

        results = Proposal.search('')
        expect(results).to eq([])
      end

    end
  end

  describe "#last_week" do
    it "should return proposals created this week" do
      proposal = create(:proposal)
      expect(Proposal.last_week.all).to include (proposal)
    end

    it "should not show proposals created more than a week ago" do
      proposal = create(:proposal, created_at: 8.days.ago)
      expect(Proposal.last_week.all).to_not include (proposal)
    end
  end

end
