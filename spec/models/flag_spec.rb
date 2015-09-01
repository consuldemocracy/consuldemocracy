require 'rails_helper'

describe Flag do

  let(:user) { create(:user) }
  let(:comment) { create(:comment) }

  describe '.flag!' do

    it 'creates a flag when there is none' do
      expect { described_class.flag!(user, comment) }.to change{ Flag.count }.by(1)
      expect(Flag.last.user).to eq(user)
      expect(Flag.last.flaggable).to eq(comment)
    end

    it 'raises an error if the flag has already been created' do
      described_class.flag!(user, comment)
      expect { described_class.flag!(user, comment) }.to raise_error(Flag::AlreadyFlaggedError)
    end

    it 'increases the flag count' do
      expect { described_class.flag!(user, comment) }.to change{ comment.reload.flags_count }.by(1)
    end
  end

  describe '.unflag!' do
    it 'raises an error if the flag does not exist' do
      expect { described_class.unflag!(user, comment) }.to raise_error(Flag::NotFlaggedError)
    end

    describe 'when the flag already exists' do
      before(:each) { described_class.flag!(user, comment) }

      it 'removes an existing flag' do
        expect { described_class.unflag!(user, comment) }.to change{ Flag.count }.by(-1)
      end

      it 'decreases the flag count' do
        expect { described_class.unflag!(user, comment) }.to change{ comment.reload.flags_count }.by(-1)
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

  describe '.create_cache' do
    let(:user) { create(:user) }
    let(:debate1) { create(:debate) }
    let(:debate2) { create(:debate) }

    it 'accepts a user & collection of flaggables' do
      expect{ Flag.build_cache(user, [debate2, debate1]) }.to_not raise_error
    end

    it 'returns nil if the item was not used for building the cache' do
      cache = Flag.build_cache(user, [debate2])
      expect(cache[debate1.id]).to eq(nil)
    end

    it 'returns true if the item was flagged by the user, false if not' do
      Flag.flag!(user, debate1)
      cache = Flag.build_cache(user, [debate1, debate2])
      expect(cache[debate1.id]).to eq(true)
      expect(cache[debate2.id]).to eq(false)
    end
  end

end
