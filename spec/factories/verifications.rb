FactoryBot.define do
  factory :local_census_record, class: "LocalCensusRecord" do
    document_number "12345678A"
    document_type 1
    date_of_birth Date.new(1970, 1, 31)
    postal_code "28002"
  end

  sequence(:document_number) { |n| "#{n.to_s.rjust(8, '0')}X" }

  factory :verification_residence, class: Verification::Residence do
    user
    document_number
    document_type    "1"
    date_of_birth    { Time.zone.local(1980, 12, 31).to_date }
    postal_code      "28013"
    terms_of_service "1"

    trait :invalid do
      postal_code "28001"
    end
  end

  factory :failed_census_call do
    user
    document_number
    document_type 1
    date_of_birth Date.new(1900, 1, 1)
    postal_code "28000"
  end

  factory :verification_sms, class: Verification::Sms do
    phone "699999999"
  end

  factory :verification_letter, class: Verification::Letter do
    user
    email "user@consul.dev"
    password "1234"
    verification_code "5555"
  end

  factory :lock do
    user
    tries 0
    locked_until { Time.current }
  end

  factory :verified_user do
    document_number
    document_type "dni"
  end
end
