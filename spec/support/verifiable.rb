shared_examples_for "verifiable" do
  let(:model) { described_class }

  describe "#scopes" do
    describe "#level_three_verified" do
      it "returns level three verified users" do
        user1 = create(:user, verified_at: Time.current)
        user2 = create(:user, verified_at: nil)

        expect(model.level_three_verified).to include(user1)
        expect(model.level_three_verified).to_not include(user2)
      end
    end

    describe "#level_two_verified" do
      it "returns level two verified users" do
        user1 = create(:user, confirmed_phone: "123456789", residence_verified_at: Time.current)
        user2 = create(:user, confirmed_phone: "123456789", residence_verified_at: nil)
        user3 = create(:user, confirmed_phone: nil, residence_verified_at: Time.current)
        user4 = create(:user, level_two_verified_at: Time.current)

        expect(model.level_two_verified).to include(user1)
        expect(model.level_two_verified).to_not include(user2)
        expect(model.level_two_verified).to_not include(user3)
        expect(model.level_two_verified).to include(user4)
      end
    end

    describe "#level_two_or_three_verified" do
      it "returns level two or three verified users" do
        user1 = create(:user, confirmed_phone: "123456789", residence_verified_at: Time.current)
        user2 = create(:user, verified_at: Time.current)
        user3 = create(:user, confirmed_phone: "123456789", residence_verified_at: nil)
        user4 = create(:user, confirmed_phone: nil, residence_verified_at: Time.current)
        user5 = create(:user, level_two_verified_at: Time.current)

        expect(model.level_two_or_three_verified).to include(user1)
        expect(model.level_two_or_three_verified).to include(user2)
        expect(model.level_two_or_three_verified).to_not include(user3)
        expect(model.level_two_or_three_verified).to_not include(user4)
        expect(model.level_two_or_three_verified).to include(user5)
      end
    end

    describe "#unverified" do
      it "returns unverified users" do
        user1 = create(:user, verified_at: nil, confirmed_phone: nil)
        user2 = create(:user, verified_at: nil, residence_verified_at: nil, confirmed_phone: "123456789")
        user3 = create(:user, verified_at: nil, residence_verified_at: Time.current, confirmed_phone: nil)
        user4 = create(:user, verified_at: Time.current, residence_verified_at: Time.current, confirmed_phone: "123456789")
        user5 = create(:user, level_two_verified_at: Time.current)

        expect(model.unverified).to include(user1)
        expect(model.unverified).to include(user2)
        expect(model.unverified).to include(user3)
        expect(model.unverified).to_not include(user4)
        expect(model.unverified).to_not include(user5)
      end
    end

    describe "#incomplete_verification" do
      it "returns users with incomplete verifications" do
        user1 = create(:user, verified_at: nil, confirmed_phone: nil)
        create(:failed_census_call, user: user1)

        user2 = create(:user, verified_at: nil, residence_verified_at: Time.current, unconfirmed_phone: nil)
        user3 = create(:user, verified_at: nil, confirmed_phone: nil)
        user4 = create(:user, verified_at: Time.current, residence_verified_at: Time.current,
                              unconfirmed_phone: "123456789", confirmed_phone: "123456789")

        expect(model.incomplete_verification).to include(user1)
        expect(model.incomplete_verification).to include(user2)
        expect(model.incomplete_verification).to_not include(user3)
        expect(model.incomplete_verification).to_not include(user4)
      end
    end
  end

  describe "#methods" do
    it "residence_verified? is true only if residence_verified_at" do
      user = create(:user, residence_verified_at: Time.current)
      expect(user.residence_verified?).to eq(true)

      user = create(:user, residence_verified_at: nil)
      expect(user.residence_verified?).to eq(false)
    end

    it "sms_verified? is true only if confirmed_phone" do
      user = create(:user, confirmed_phone: "123456789")
      expect(user.sms_verified?).to eq(true)

      user = create(:user, confirmed_phone: nil)
      expect(user.sms_verified?).to eq(false)
    end

    it "level_two_verified? is true if manually set, or if residence_verified_at and confirmed_phone" do
      user = create(:user, level_two_verified_at: Time.current)
      expect(user.level_two_verified?).to eq(true)

      user = create(:user, confirmed_phone: "123456789", residence_verified_at: Time.current)
      expect(user.level_two_verified?).to eq(true)

      user = create(:user, confirmed_phone: nil, residence_verified_at: Time.current)
      expect(user.level_two_verified?).to eq(false)

      user = create(:user, confirmed_phone: "123456789", residence_verified_at: nil)
      expect(user.level_two_verified?).to eq(false)
    end

    it "level_three_verified? is true only if verified_at" do
      user = create(:user, verified_at: Time.current)
      expect(user.level_three_verified?).to eq(true)

      user = create(:user, verified_at: nil)
      expect(user.level_three_verified?).to eq(false)
    end

    it "unverified? is true only if not level_three_verified and not level_two_verified" do
      user = create(:user, verified_at: nil, confirmed_phone: nil)
      expect(user.unverified?).to eq(true)

      user = create(:user, verified_at: Time.current, confirmed_phone: "123456789", residence_verified_at: Time.current)
      expect(user.unverified?).to eq(false)
    end

    it "verification_email_sent? is true only if user has email_verification_token" do
      user = create(:user, email_verification_token: "xxxxxxx")
      expect(user.verification_email_sent?).to eq(true)

      user = create(:user, email_verification_token: nil)
      expect(user.verification_email_sent?).to eq(false)
    end

    it "verification_sms_sent? is true only if user has unconfirmed_phone and sms_confirmation_code" do
      user = create(:user, unconfirmed_phone: "666666666", sms_confirmation_code: "666")
      expect(user.verification_sms_sent?).to eq(true)

      user = create(:user, unconfirmed_phone: nil, sms_confirmation_code: "666")
      expect(user.verification_sms_sent?).to eq(false)

      user = create(:user, unconfirmed_phone: "666666666", sms_confirmation_code: nil)
      expect(user.verification_sms_sent?).to eq(false)

      user = create(:user, unconfirmed_phone: nil, sms_confirmation_code: nil)
      expect(user.verification_sms_sent?).to eq(false)
    end

    it "verification_letter_sent? is true only if user has letter_requested_at and letter_verification_code" do
      user = create(:user, letter_requested_at: Time.current, letter_verification_code: "666")
      expect(user.verification_letter_sent?).to eq(true)

      user = create(:user, letter_requested_at: nil, letter_verification_code: "666")
      expect(user.verification_letter_sent?).to eq(false)

      user = create(:user, letter_requested_at: Time.current, letter_verification_code: nil)
      expect(user.verification_letter_sent?).to eq(false)

      user = create(:user, letter_requested_at: nil, letter_verification_code: nil)
      expect(user.verification_letter_sent?).to eq(false)
    end
  end

end
