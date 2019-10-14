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
end
