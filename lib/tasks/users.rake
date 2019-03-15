namespace :users do

  desc "Enable recommendations for existing users"
  task enable_recommendations: :environment do
    User.find_each do |user|
      user.update(recommended_debates: true, recommended_proposals: true)
    end
  end

  desc "Create superuser"
  require 'faker'
  task superuser: :environment do
      email = Faker::Internet.email
      password = Faker::Internet.password
      puts "Superuser created. You can log in with \"#{email}\" using \"#{password}\" as password"

      silence_stream(STDOUT) do
          admin = create_user(email, password)
          admin.create_administrator
          admin.update(residence_verified_at: Time.current,
              confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
              verified_at: Time.current, document_number: Faker::Code.npi)
      end
  end

  def create_user(email, password)
      User.create!(
        username:               Faker::Name.name,
        email:                  email,
        password:               password,
        password_confirmation:  password,
        confirmed_at:           Time.current,
        terms_of_service:       "1",
        gender:                 ['Male', 'Female'].sample,
        date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
        public_activity:        (rand(1..100) > 30)
      )
  end
end
