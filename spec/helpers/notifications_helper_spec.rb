require 'rails_helper'

describe NotificationsHelper do

  describe "#notification_action" do
    let(:debate) { create :debate }
    let(:debate_comment) { create :comment, commentable: debate }

    context "when action was comment on a debate" do
      it "returns correct text when someone comments on your debate" do
        notification = create :notification, notifiable: debate
        expect(notification_action(notification)).to eq "comments_on"
      end
    end

    context "when action was comment on a debate" do
      it "returns correct text when someone replies to your comment" do
        notification = create :notification, notifiable: debate_comment
        expect(notification_action(notification)).to eq "replies_to"
      end
    end
  end


end
