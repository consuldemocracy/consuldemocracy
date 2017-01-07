require 'rails_helper'

describe 'Vote' do

  describe '#for_debates' do
    it 'does not returns votes for other votables' do
      debate = create(:debate)
      comment = create(:comment)
      create(:vote, votable: comment)

      expect(Vote.for_debates(debate).count).to eq(0)
    end

    it 'returns votes only for debates in parameters' do
      debate1 = create(:debate)
      debate2 = create(:debate)
      create(:vote, votable: debate1)

      expect(Vote.for_debates(debate1).count).to eq(1)
      expect(Vote.for_debates(debate2).count).to eq(0)
    end

    it 'accepts more than 1 debate' do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, votable: debate1)
      create(:vote, votable: debate3)

      expect(Vote.for_debates([debate1, debate2]).count).to eq(1)
    end
  end

  describe '#value' do
    it 'returns vote flag' do
      vote = create(:vote, vote_flag: true)
      expect(vote.value).to eq(true)

      vote = create(:vote, vote_flag: false)
      expect(vote.value).to eq(false)
    end
  end

  describe 'public_for_api scope' do
    it 'returns votes on debates' do
      debate = create(:debate)
      vote = create(:vote, votable: debate)

      expect(Vote.public_for_api).to include(vote)
    end

    it 'blocks votes on hidden debates' do
      debate = create(:debate, :hidden)
      vote = create(:vote, votable: debate)

      expect(Vote.public_for_api).not_to include(vote)
    end

    it 'returns votes on proposals' do
      proposal = create(:proposal)
      vote = create(:vote, votable: proposal)

      expect(Vote.public_for_api).to include(vote)
    end

    it 'blocks votes on hidden proposals' do
      proposal = create(:proposal, :hidden)
      vote = create(:vote, votable: proposal)

      expect(Vote.public_for_api).not_to include(vote)
    end

    it 'returns votes on comments' do
      comment = create(:comment)
      vote = create(:vote, votable: comment)

      expect(Vote.public_for_api).to include(vote)
    end

    it 'blocks votes on hidden comments' do
      comment = create(:comment, :hidden)
      vote = create(:vote, votable: comment)

      expect(Vote.public_for_api).not_to include(vote)
    end

    it 'blocks any other kind of votes' do
      spending_proposal = create(:spending_proposal)
      vote = create(:vote, votable: spending_proposal)

      expect(Vote.public_for_api).not_to include(vote)
    end
  end

  describe 'public_voter' do
    it 'only returns voter if votable has enough votes' do
      create(:setting, key: 'proposal_api_votes_threshold', value: '2')

      proposal_1 = create(:proposal)
      proposal_2 = create(:proposal)

      voter_1 = create(:user)
      voter_2 = create(:user)

      vote_1 = create(:vote, votable: proposal_1, voter: voter_1)
      vote_2 = create(:vote, votable: proposal_2, voter: voter_1)
      vote_3 = create(:vote, votable: proposal_2, voter: voter_2)

      expect(vote_1.public_voter).to be_nil
      expect(vote_2.public_voter).to eq(voter_1)
    end
  end

  describe '#public_timestamp' do
    it "truncates created_at timestamp up to minutes" do
      vote = create(:vote, created_at: Time.zone.parse('2016-02-10 15:30:45'))
      expect(vote.public_timestamp).to eq(Time.zone.parse('2016-02-10 15:00:00'))
    end
  end
end
