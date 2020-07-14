# Models

If you need to create new models or customize existent ones, you can do it so at the `app/models/custom` folder. Keep in mind that for old models you'll need to firstly require the dependency.

For example for Madrid's City Hall fork its required to check the zip code's format \(it always starts with 280 followed by 2 digits\). That check is at `app/models/custom/verification/residence.rb`:

```ruby
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :postal_code_in_madrid
  validate :residence_in_madrid

  def postal_code_in_madrid
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_madrid
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_madrid, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def valid_postal_code?
      postal_code =~ /^280/
    end

end
```

Do not forget to cover your changes with a test at the `spec/models/custom` folder. Following the example we could create `spec/models/custom/residence_spec.rb`:

```ruby
require 'rails_helper'

describe Verification::Residence do

  let(:residence) { build(:verification_residence, document_number: "12345678Z") }

  describe "verification" do

    describe "postal code" do
      it "should be valid with postal codes starting with 280" do
        residence.postal_code = "28012"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)

        residence.postal_code = "28023"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)
      end

      it "should not be valid with postal codes not starting with 280" do
        residence.postal_code = "12345"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)

        residence.postal_code = "13280"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)
        expect(residence.errors[:postal_code]).to include("In order to be verified, you must be registered in the municipality of Madrid.")
      end
    end

  end

end
```

