shared_examples "notifiable" do

  let(:notifiable) { create(model_name(described_class)) }

  describe "#notification_title" do

    it "returns the notifiable title when it's a root comment" do
      notification = create(:notification, notifiable: notifiable)

      expect(notification.notifiable_title).to eq notifiable.title
    end

    it "returns the notifiable title when it's a reply to a root comment" do
      comment = create(:comment, commentable: notifiable)
      notification = create(:notification, notifiable: comment)

      expect(notification.notifiable_title).to eq notifiable.title
    end

  end

  describe "notifiable_available?" do

    it "returns true when it's a root comment and the notifiable is available" do
      notification = create(:notification, notifiable: notifiable)

      expect(notification.notifiable_available?).to be(true)
    end

    it "returns true when it's a reply to comment and the notifiable is available" do
      comment = create(:comment, commentable: notifiable)
      notification = create(:notification, notifiable: comment)

      expect(notification.notifiable_available?).to be(true)
    end

    it "returns false when it's a root comment and the notifiable has been hidden" do
      notification = create(:notification, notifiable: notifiable)

      notifiable.hide
      notification.reload

      expect(notification.notifiable_available?).not_to be(true)
    end

    it "returns false when it's a reply to comment and the commentable has been hidden" do
      comment = create(:comment, commentable: notifiable)
      notification = create(:notification, notifiable: comment)

      notifiable.hide
      notification.reload

      expect(notification.notifiable_available?).to be(false)
    end

  end

  describe "check_availability" do

    it "returns true if the resource is present, not hidden, nor retired" do
      notification = create(:notification, notifiable: notifiable)
      expect(notification.check_availability(notifiable)).to be(true)
    end

    it "returns false if the resource is not present" do
      notification = create(:notification, notifiable: notifiable)
      notifiable.really_destroy!
      expect(notification.check_availability(notifiable)).to be(false)
    end

    it "returns false if the resource is not hidden" do
      notification = create(:notification, notifiable: notifiable)
      notifiable.hide
      expect(notification.check_availability(notifiable)).to be(false)
    end

    it "returns false if the resource is retired" do
      notification = create(:notification, notifiable: notifiable)

      if notifiable.respond_to?(:retired_at)
        notifiable.update(retired_at: Time.current)
        expect(notification.check_availability(notifiable)).to be(false)
      end
    end

  end

end
