section "Creating Users" do
  def create_user(email, username = Faker::Name.name)
    pwd = "12345678"
    User.create!(
      username:               username,
      email:                  email,
      password:               pwd,
      password_confirmation:  pwd,
      confirmed_at:           Time.current,
      terms_of_service:       "1",
      gender:                 %w[male female].sample,
      date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
      public_activity:        (rand(1..100) > 30)
    )
  end

  def unique_document_number
    @document_number ||= 12345678
    @document_number += 1
    "#{@document_number}#{[*"A".."Z"].sample}"
  end

  admin = create_user("admin@madrid.es", "admin")
  admin.create_administrator
  admin.update(residence_verified_at: Time.current,
               confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
               verified_at: Time.current, document_number: unique_document_number)
  admin.create_poll_officer

  moderator = create_user("mod@madrid.es", "mod")
  moderator.create_moderator
  moderator.update(residence_verified_at: Time.current,
                   confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                   verified_at: Time.current, document_number: unique_document_number)

  manager = create_user("manager@madrid.es", "manager")
  manager.create_manager
  manager.update(residence_verified_at: Time.current,
                 confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                 verified_at: Time.current, document_number: unique_document_number)

  10.times do |i|
    valuator = create_user("valuator#{i}@madrid.es", "Valuator #{i}")
    valuator.create_valuator
    valuator.update(residence_verified_at: Time.current,
                    confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                    verified_at: Time.current, document_number: unique_document_number)
  end

  poll_officer = create_user("poll_officer@madrid.es", "Paul O. Fisher")
  poll_officer.create_poll_officer
  poll_officer.update(residence_verified_at: Time.current,
                      confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                      verified_at: Time.current, document_number: unique_document_number)

  poll_officer2 = create_user("poll_officer2@madrid.es", "Pauline M. Espinosa")
  poll_officer2.create_poll_officer
  poll_officer2.update(residence_verified_at: Time.current,
                       confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                       verified_at: Time.current, document_number: unique_document_number)

  create_user("unverified@madrid.es", "unverified")

  level_2 = create_user("leveltwo@madrid.es", "level 2")
  level_2.update(residence_verified_at: Time.current,
                 confirmed_phone: Faker::PhoneNumber.phone_number,
                 document_number: unique_document_number, document_type: "1")

  verified = create_user("verified@madrid.es", "verified")
  verified.update(residence_verified_at: Time.current,
                  confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                  verified_at: Time.current, document_number: unique_document_number)

  (1..10).each do |i|
    org_name = Faker::Company.name
    org_user = create_user("org#{i}@madrid.es", org_name)
    org_responsible_name = Faker::Name.name
    org = org_user.create_organization(name: org_name, responsible_name: org_responsible_name)

    verified = [true, false].sample
    if verified
      org.verify
    else
      org.reject
    end
  end

  (1..5).each do |i|
    official = create_user("official#{i}@madrid.es")
    official.update(official_level: i, official_position: "Official position #{i}")
  end

  (1..40).each do |i|
    user = create_user("user#{i}@madrid.es")
    level = [1, 2, 3].sample
    if level >= 2
      user.update(residence_verified_at: Time.current,
                  confirmed_phone: Faker::PhoneNumber.phone_number,
                  document_number: unique_document_number,
                  document_type: "1",
                  geozone: Geozone.all.sample)
    end
    if level == 3
      user.update(verified_at: Time.current, document_number: Faker::Number.number(10))
    end
  end
end
