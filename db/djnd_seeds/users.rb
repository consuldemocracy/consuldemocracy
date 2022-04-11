# coding: utf-8

section "Creating Users" do
    def create_user(email, username = Faker::Name.name)
      password = "12345678"
      User.create!(
        username:               username,
        email:                  email,
        password:               password,
        password_confirmation:  password,
        confirmed_at:           Time.current,
        terms_of_service:       "1",
        gender:                 ["Male", "Female"].sample,
        date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
        public_activity:        (rand(1..100) > 30),
        document_number:        unique_document_number
      )
    end
  
    def fix_my_emso(document_number)
      if /[0123]\d[01]\d[09]\d\d\d{6}/.match(document_number)
        if document_number[12].to_i == 11 - (
          (
            ((document_number[0].to_i + document_number[6].to_i) * 7) +
            ((document_number[1].to_i + document_number[7].to_i) * 6) +
            ((document_number[2].to_i + document_number[8].to_i) * 5) +
            ((document_number[3].to_i + document_number[9].to_i) * 4) +
            ((document_number[4].to_i + document_number[10].to_i) * 3) +
            ((document_number[5].to_i + document_number[11].to_i) * 2)
          ) % 11
        )
          document_number
        elsif document_number[12].to_i == (
            ((document_number[0].to_i + document_number[6].to_i) * 7) +
            ((document_number[1].to_i + document_number[7].to_i) * 6) +
            ((document_number[2].to_i + document_number[8].to_i) * 5) +
            ((document_number[3].to_i + document_number[9].to_i) * 4) +
            ((document_number[4].to_i + document_number[10].to_i) * 3) +
            ((document_number[5].to_i + document_number[11].to_i) * 2)
          ) % 11
          document_number
        else
          document_number[0..11] +
          (
          (
            ((document_number[0].to_i + document_number[6].to_i) * 7) +
            ((document_number[1].to_i + document_number[7].to_i) * 6) +
            ((document_number[2].to_i + document_number[8].to_i) * 5) +
            ((document_number[3].to_i + document_number[9].to_i) * 4) +
            ((document_number[4].to_i + document_number[10].to_i) * 3) +
            ((document_number[5].to_i + document_number[11].to_i) * 2)
          ) % 11).to_s
        end
      end
    end
  
    def unique_document_number
      @document_number ||= 1203989100100
      @document_number += 20
      fix_my_emso(@document_number.to_s)
    end
  
    admin = create_user("consul@danesjenovdan.si", "admin")
    admin.create_administrator
    admin.update!(residence_verified_at: Time.current,
                 confirmed_phone: "1234567890", document_type: "1",
                 verified_at: Time.current, document_number: unique_document_number)
  
    # moderator = create_user("consul+mod@danesjenovdan.si", "moderator")
    # moderator.create_moderator
    # moderator.update(residence_verified_at: Time.current,
    #                  confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
    #                  verified_at: Time.current, document_number: unique_document_number)
  
    manager = create_user("consul+manager@danesjenovdan.si", "manager")
    manager.create_manager
    manager.update!(residence_verified_at: Time.current,
                   confirmed_phone: "1234567890", document_type: "1",
                   verified_at: Time.current, document_number: unique_document_number)
  
    # valuator = create_user("valuator@consul.dev", "valuator")
    # valuator.create_valuator
    # valuator.update(residence_verified_at: Time.current,
    #                 confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
    #                 verified_at: Time.current, document_number: unique_document_number)
  
    # poll_officer = create_user("poll_officer@consul.dev", "Paul O. Fisher")
    # poll_officer.create_poll_officer
    # poll_officer.update(residence_verified_at: Time.current,
    #                     confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
    #                     verified_at: Time.current, document_number: unique_document_number)
  
    # poll_officer2 = create_user("poll_officer2@consul.dev", "Pauline M. Espinosa")
    # poll_officer2.create_poll_officer
    # poll_officer2.update(residence_verified_at: Time.current,
    #                      confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
    #                      verified_at: Time.current, document_number: unique_document_number)
  
    # create_user("unverified@consul.dev", "unverified")
  
    # level_2 = create_user("leveltwo@consul.dev", "level 2")
    # level_2.update(residence_verified_at: Time.current,
    #                confirmed_phone: Faker::PhoneNumber.phone_number,
    #                document_number: unique_document_number, document_type: "1")
  
    # verified = create_user("verified@consul.dev", "verified")
    # verified.update(residence_verified_at: Time.current,
    #                 confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
    #                 verified_at: Time.current, document_number: unique_document_number)
  
    # [
    #   I18n.t("seeds.organizations.neighborhood_association"),
    #   I18n.t("seeds.organizations.human_rights"),
    #   "Greenpeace"
    # ].each do |organization_name|
    #   org_user = create_user("#{organization_name.parameterize}@consul.dev", organization_name)
    #   org = org_user.create_organization(name: organization_name, responsible_name: Faker::Name.name)
    #   [true, false].cycle ? org.verify : org.reject
    # end
  
    # 5.times do |i|
    #   official = create_user("official#{i}@consul.dev")
    #   official.update(official_level: i, official_position: "Official position #{i}")
    # end
  
    # 30.times do |i|
    #   user = create_user("user#{i}@consul.dev")
    #   level = [1, 2, 3].sample
    #   if level >= 2
    #     user.update(residence_verified_at: Time.current,
    #                 confirmed_phone: Faker::PhoneNumber.phone_number,
    #                 document_number: unique_document_number,
    #                 document_type: "1",
    #                 geozone: Geozone.all.sample)
    #   end
    #   if level == 3
    #     user.update(verified_at: Time.current, document_number: unique_document_number)
    #   end
    # end
  end
  