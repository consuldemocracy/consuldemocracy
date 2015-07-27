require 'rails_helper'

describe RecaptchaHelper do

  describe "#recaptcha_keys?" do

    it "should be true if Recaptcha keys are configured" do
      allow(Recaptcha.configuration).to receive(:public_key).and_return("akjasf")
      allow(Recaptcha.configuration).to receive(:private_key).and_return("akjasf4532")

      expect(helper.recaptcha_keys?).to be true
    end

    it "should be false if Recaptcha keys are not configured" do
      allow(Recaptcha.configuration).to receive(:public_key).and_return(nil)
      allow(Recaptcha.configuration).to receive(:private_key).and_return(nil)

      expect(helper.recaptcha_keys?).to be false
    end

  end
end
