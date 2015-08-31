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

  describe '.by_user_and_flaggables' do
    let(:user) { create(:user) }
    let(:debate) { create(:debate) }
    let(:comment) { create(:comment) }
    it 'returns an empty scope when no flaggables are given' do
      Flag.flag!(user, create(:debate))
      expect(Flag.by_user_and_flaggables(user, [])).to be_empty
    end
    it 'returns an empty list of flags if there are no flags' do
      expect(Flag.by_user_and_flaggables(user, [debate, comment])).to be_empty
    end

    it 'builds a single query to retrieve all the flags' do
      Flag.flag!(user, debate)
      Flag.flag!(user, comment)
      flags = Flag.by_user_and_flaggables(user, [debate, comment])
      expect(flags.count).to eq(2)
      expect(flags.pluck(:flaggable_type).sort).to eq(['Comment', 'Debate'])
      expect(flags.pluck(:flaggable_id)).to include(debate.id, comment.id)
    end
  end


  describe Flag::Cache do
    let(:user) { create(:user) }
    let(:debate) { create(:debate) }
    let(:comment) { create(:comment) }

    it 'accepts a user and a collection of flaggables' do
      expect{ Flag::Cache.new(user, [comment, debate]) }.to_not raise_error
    end

    describe '#flagged?' do
      it 'returns false if the item was not flagged by the user' do
        cache = Flag::Cache.new(user, [debate, comment])
        expect(cache.flagged?(debate)).to eq(false)
      end

      it 'returns true if the item was flagged by the user' do
        Flag.flag!(user, debate)
        cache = Flag::Cache.new(user, [debate, comment])
        expect(cache.flagged?(debate)).to eq(true)
        expect(cache.flagged?(comment)).to eq(false)
      end

      it 'returns nil if the item was not used for building the cache' do
        cache = Flag::Cache.new(user, [comment])
        expect(cache.flagged?(debate)).to eq(nil)
      end
    end

    describe '#knows?' do
      it 'returns false if the flaggable was not used for building the cache' do
        cache = Flag::Cache.new(user, [debate])
        expect(cache.knows?(comment)).to eq(false)
      end

      it 'returns true if the flaggable was used for building the cache, independently of wether it was flagged or not' do
        cache = Flag::Cache.new(user, [debate])
        expect(cache.knows?(debate)).to eq(true)

        Flag.flag!(user, debate)
        cache = Flag::Cache.new(user, [debate])
        expect(cache.knows?(debate)).to eq(true)
      end
    end

  end

end
