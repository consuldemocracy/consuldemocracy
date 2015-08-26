require 'rails_helper'

describe 'Vote' do

  describe '#for_debates' do
    it 'returns votes for debates' do
      debate = create(:debate)
      create(:user).vote_up_for(debate)

      expect(Vote.for_debates.count).to eq(1)
    end

    it 'does not returns votes for other votables' do
      comment = create(:comment)
      create(:user).vote_up_for(comment)

      expect(Vote.for_debates.count).to eq(0)
    end
  end

  describe '#in' do
    it 'returns debates send in parameters' do
      debate = create(:debate)
      create(:user).vote_up_for(debate)

      expect(Vote.in(debate).count).to eq(1)
    end

    it 'does not return debates not in parameters' do
      debate = create(:debate)
      create(:user).vote_up_for(debate)

      expect(Vote.in([]).count).to eq(0)
    end
  end

  describe '#value' do
    it 'returns vote flag' do
      debate = create(:debate)

      create(:user).vote_up_for(debate)
      create(:user).vote_down_for(debate)

      expect(debate.get_positives.first.value).to eq(true)
      expect(debate.get_negatives.first.value).to eq(false)
    end
  end
end
