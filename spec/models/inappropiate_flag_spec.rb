require 'rails_helper'

describe InappropiateFlag do

  let(:user) { create(:user) }
  let(:comment) { create(:comment) }

  describe '.flag!' do

    it 'creates a flag when there is none' do
      expect { described_class.flag!(user, comment) }.to change{ InappropiateFlag.count }.by(1)
      expect(InappropiateFlag.last.user).to eq(user)
      expect(InappropiateFlag.last.flaggable).to eq(comment)
    end

    it 'raises an error if the flag has already been created' do
      described_class.flag!(user, comment)
      expect { described_class.flag!(user, comment) }.to raise_error(InappropiateFlag::AlreadyFlaggedError)
    end

    it 'increases the flag count' do
      expect { described_class.flag!(user, comment) }.to change{ comment.reload.inappropiate_flags_count }.by(1)
    end

    it 'updates the flagged_as date' do
      expect { described_class.flag!(user, comment) }.to change{ comment.reload.flagged_as_inappropiate_at }
    end
  end

  describe '.unflag!' do
    it 'raises an error if the flag does not exist' do
      expect { described_class.unflag!(user, comment) }.to raise_error(InappropiateFlag::NotFlaggedError)
    end

    describe 'when the flag already exists' do
      before(:each) { described_class.flag!(user, comment) }

      it 'removes an existing flag' do
        expect { described_class.unflag!(user, comment) }.to change{ InappropiateFlag.count }.by(-1)
      end

      it 'decreases the flag count' do
        expect { described_class.unflag!(user, comment) }.to change{ comment.reload.inappropiate_flags_count }.by(-1)
      end

      it 'does not update the flagged_as date' do
        expect { described_class.unflag!(user, comment) }.to_not change{ comment.flagged_as_inappropiate_at }
      end
    end

  end

  describe '.flagged?' do
    it 'returns false when the user has not flagged the comment' do
      expect(described_class.flagged?(user, comment)).to_not be
    end

    it 'returns true when the user has flagged the comment' do
      described_class.flag!(user, comment)
      expect(described_class.flagged?(user, comment)).to be
    end
  end

end
