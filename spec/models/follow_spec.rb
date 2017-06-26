require 'rails_helper'

describe Follow do

  let(:follow) { build(:follow, :followed_proposal) }

  # it_behaves_like "has_public_author"

  it "should be valid" do
    expect(follow).to be_valid
  end

  it "should not be valid without an user_id" do
    follow.user_id = nil
    expect(follow).to_not be_valid
  end

  it "should not be valid without an followable_id" do
    follow.followable_id = nil
    expect(follow).to_not be_valid
  end

  it "should not be valid without an followable_type" do
    follow.followable_type = nil
    expect(follow).to_not be_valid
  end


  # describe "proposal" do
  #
  #   let(:proposal) { create(:proposal) }
  #
  #   describe 'create' do
  #
  #     it 'creates a interest when there is none' do
  #       expect { described_class.follow(user, proposal) }.to change{ Interest.count }.by(1)
  #       expect(Interest.last.user).to eq(user)
  #       expect(Interest.last.interestable).to eq(proposal)
  #     end
  #
  #     it 'does nothing if the interest already exists' do
  #       described_class.follow(user, proposal)
  #       expect(described_class.follow(user, proposal)).to eq(false)
  #       expect(Interest.by_user_and_interestable(user, proposal).count).to eq(1)
  #     end
  #
  #     it 'increases the interest count' do
  #       expect { described_class.follow(user, proposal) }.to change{ proposal.reload.interests_count }.by(1)
  #     end
  #   end
  #
  #   describe 'destroy' do
  #     it 'raises an error if the interest does not exist' do
  #       expect(described_class.unfollow(user, proposal)).to eq(false)
  #     end
  #
  #     describe 'when the interest already exists' do
  #       before(:each) { described_class.follow(user, proposal) }
  #
  #       it 'removes an existing interest' do
  #         expect { described_class.unfollow(user, proposal) }.to change{ Interest.count }.by(-1)
  #       end
  #
  #       it 'decreases the interest count' do
  #         expect { described_class.unfollow(user, proposal) }.to change{ proposal.reload.interests_count }.by(-1)
  #       end
  #     end
  #   end
  #
  #   describe '.interested?' do
  #     it 'returns false when the user has not flagged the proposal' do
  #       expect(described_class.interested?(user, proposal)).to_not be
  #     end
  #
  #     it 'returns true when the user has interested the proposal' do
  #       described_class.follow(user, proposal)
  #       expect(described_class.interested?(user, proposal)).to be
  #     end
  #   end
  # end
  #
  # describe "debate" do
  #
  #   let(:debate) { create(:debate) }
  #
  #   describe 'create' do
  #
  #     it 'creates a interest when there is none' do
  #       expect { described_class.follow(user, debate) }.to change{ Interest.count }.by(1)
  #       expect(Interest.last.user).to eq(user)
  #       expect(Interest.last.interestable).to eq(debate)
  #     end
  #
  #     it 'does nothing if the interest already exists' do
  #       described_class.follow(user, debate)
  #       expect(described_class.follow(user, debate)).to eq(false)
  #       expect(Interest.by_user_and_interestable(user, debate).count).to eq(1)
  #     end
  #
  #     it 'increases the interest count' do
  #       expect { described_class.follow(user, debate) }.to change{ debate.reload.interests_count }.by(1)
  #     end
  #   end
  #
  #   describe 'destroy' do
  #     it 'raises an error if the interest does not exist' do
  #       expect(described_class.unfollow(user, debate)).to eq(false)
  #     end
  #
  #     describe 'when the interest already exists' do
  #       before(:each) { described_class.follow(user, debate) }
  #
  #       it 'removes an existing interest' do
  #         expect { described_class.unfollow(user, debate) }.to change{ Interest.count }.by(-1)
  #       end
  #
  #       it 'decreases the interest count' do
  #         expect { described_class.unfollow(user, debate) }.to change{ debate.reload.interests_count }.by(-1)
  #       end
  #     end
  #   end
  #
  #   describe '.interested?' do
  #     it 'returns false when the user has not flagged the debate' do
  #       expect(described_class.interested?(user, debate)).to_not be
  #     end
  #
  #     it 'returns true when the user has interested the debate' do
  #       described_class.follow(user, debate)
  #       expect(described_class.interested?(user, debate)).to be
  #     end
  #   end
  # end
end
