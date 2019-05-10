require "rails_helper"

describe Flag do

  let(:user) { create(:user) }
  let(:comment) { create(:comment) }

  describe ".flag" do

    it "creates a flag when there is none" do
      expect { described_class.flag(user, comment) }.to change{ described_class.count }.by(1)
      expect(described_class.last.user).to eq(user)
      expect(described_class.last.flaggable).to eq(comment)
    end

    it "does nothing if the flag already exists" do
      described_class.flag(user, comment)
      expect(described_class.flag(user, comment)).to eq(false)
      expect(described_class.by_user_and_flaggable(user, comment).count).to eq(1)
    end

    it "increases the flag count" do
      expect { described_class.flag(user, comment) }.to change{ comment.reload.flags_count }.by(1)
    end
  end

  describe ".unflag" do
    it "raises an error if the flag does not exist" do
      expect(described_class.unflag(user, comment)).to eq(false)
    end

    describe "when the flag already exists" do
      before { described_class.flag(user, comment) }

      it "removes an existing flag" do
        expect { described_class.unflag(user, comment) }.to change{ described_class.count }.by(-1)
      end

      it "decreases the flag count" do
        expect { described_class.unflag(user, comment) }.to change{ comment.reload.flags_count }.by(-1)
      end
    end
  end

  describe ".flagged?" do
    it "returns false when the user has not flagged the comment" do
      expect(described_class.flagged?(user, comment)).not_to be
    end

    it "returns true when the user has flagged the comment" do
      described_class.flag(user, comment)
      expect(described_class.flagged?(user, comment)).to be
    end
  end

end
