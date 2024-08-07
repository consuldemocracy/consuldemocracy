require 'csv'
require 'faker'

namespace :import do
  # Usage: rake import:generate_users[prefix, number]
  #   - prefix: Custom prefix for usernames (default: 'demo')
  #   - number: Number of users to generate (default: 6)
 
  desc 'Generate users with custom usernames and passwords'
  task :generate_users, [:prefix,:number] => :environment do | task, args| 
    username_prefix = args[:prefix] || 'demo'
    num_users = (args[:number] || 6).to_i

    # An array of four-letter words for generating passwords
     four_letter_words = Array.new(80) { Faker::Verb.base.downcase.gsub(/[\s[:punct:]]/, '') }
     places = Array.new(100) { Faker::Nation.capital_city.downcase.gsub(/[\s[:punct:]]/, '') }
    # Define a file path to store the old and new usernames
    output_file_path = "#{username_prefix}_usernames.csv" 
  
    # Open the file in append mode (creates the file if it doesn't exist)
    File.open(output_file_path, "a") do |file|
      User.transaction do
        # Initialize a global random number generator
        $random_generator ||= Random.new
        num_users.times do |i|
         username = "#{username_prefix}#{(Time.current.year % 100)}#{i + 1}"
         password = "#{places.sample}.#{four_letter_words.sample}#{$random_generator.rand(1000)}"

       begin
        user = User.create!(
          username: username,
          email: nil,  # You can customize this if needed
          password: password,
          password_confirmation: password,
          confirmed_at: Time.current,
          verified_at: Time.current,
          residence_verified_at: Time.current,
          terms_of_service: '1'
        )
       rescue ActiveRecord::RecordInvalid => e
         puts "Error creating user: #{e.message}"
         next
       end
       if user
         puts "Username: #{user.username}, Password: #{user.password}"
         file.puts "#{user.username},#{user.password}"
        end
      end
      end    
    end
  end
end
