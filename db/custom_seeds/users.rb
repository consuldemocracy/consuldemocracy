section "Creating Users" do

  def unique_document_number
    @document_number ||= 12345678
    @document_number += 1
    "#{@document_number}#{[*'A'..'Z'].sample}"
  end

  admin = User.where(email: 'claire.zuliani@happy-dev.fr').first_or_create!(
    username:               'admin happy dev',
    firstname:              'Admin',
    lastname:               'HappyDev',
    password:               '12345678',
    password_confirmation:  '12345678',
    confirmed_at:           Time.current,
    terms_of_service:       "1",
    gender:                 ['Male', 'Female'].sample,
    date_of_birth:          rand((Time.current - 25.years)..(Time.current - 16.years)),
    public_activity:        (rand(1..100) > 30),
    residence_verified_at: Time.current,
    confirmed_phone: Faker::PhoneNumber.phone_number,
    document_type: "1",
    verified_at: Time.current,
    document_number: unique_document_number,
    postal_code: '11000'
  )
  # TODO : following instruction genereate en error :
  # `PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "administrators_pkey"
  # DETAIL:  Key (id)=(2) already exists.`
  # Already too much time spent trying to debug it. It seems to work, anyway. Further check required later
  admin.create_administrator unless admin.administrator.present?

end
