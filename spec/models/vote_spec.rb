require 'rails_helper'

describe 'Vote' do

  describe '#for_debates' do
    it 'returns votes for debates' do
      debate = create(:debate)
      create(:vote, votable: debate)

      expect(Vote.for_debates.count).to eq(1)
    end

    it 'does not returns votes for other votables' do
      comment = create(:comment)
      create(:vote, votable: comment)

      expect(Vote.for_debates.count).to eq(0)
    end
  end

  describe '#in' do
    it 'returns debates send in parameters' do
      debate = create(:debate)
      create(:vote, votable: debate)

      expect(Vote.in(debate).count).to eq(1)
    end

    it 'does not return debates not in parameters' do
      debate = create(:debate)
      create(:vote, votable: debate)

      expect(Vote.in([]).count).to eq(0)
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