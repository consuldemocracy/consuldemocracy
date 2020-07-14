# Modelos

Si quieres agregar modelos nuevos, o modificar o agregar métodos a uno ya existente puedes hacerlo en `app/models/custom`. En el caso de los modelos antiguos debes primero hacer un require de la dependencia.

Por ejemplo en el caso del Ayuntamiento de Madrid se requiere comprobar que el código postal durante la verificación sigue un cierto formato \(empieza con 280\). Esto se realiza creando este fichero en `app/models/custom/verification/residence.rb`:

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

No olvides poner los tests relevantes en `spec/models/custom`, siguiendo con el ejemplo pondriamos lo siguiente en `spec/models/custom/residence_spec.rb`:

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

