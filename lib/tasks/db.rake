namespace :db do
  desc "Resets the database and loads it from db/dev_seeds.rb"
  task :dev_seed, [:print_log] => [:environment] do |t, args|
    @avoid_log = args[:print_log] == "avoid_log"
    load(Rails.root.join("db", "dev_seeds.rb"))
  end

  desc "Anonymizes DB data and creates standard users"
  task anonymize: :environment do
    unless Rails.env.development? || Rails.env.staging?
      puts "Error: this task can only be run in development or staging environments"
      exit(-1)
    end

    puts "Destroying locks..."
    Lock.destroy_all

    puts "Destroying failed census calls..."
    FailedCensusCall.destroy_all

    puts "Anonymizing users..."
    password = "consul123"
    users = User.all
    users_count = users.count

    users.each_with_index do |user, idx|
      puts "Anonymizing user #{idx + 1}/#{users_count}" if (idx % 50).zero?
      user.password = password
      user.password_confirmation = password
      user.save!(validate: false)

      user.update_columns(
        username: "user#{user.id}",
        email: "user#{user.id}@example.com",
        unconfirmed_email: nil,
        postal_code: nil,
        phone_number: nil,
        confirmed_phone: nil,
        unconfirmed_phone: nil,
        document_number: nil,
        document_type: nil
      )
    end

    puts "Creating standard users..."
    common_attrs = {
      password: password,
      password_confirmation: password,
      confirmed_at: Time.current,
      terms_of_service: "1"
    }

    10.times do |n|
      User.create!(common_attrs.merge(
        username: "verified#{n + 1}",
        email: "verified#{n + 1}@example.com",
        verified_at: Time.current,
        residence_verified_at: Time.current,
        document_number: "1234567#{n}V",
        document_type: 1
      ))

      User.create!(common_attrs.merge(
        username: "unverified#{n + 1}",
        email: "unverified#{n + 1}@example.com",
      ))

      admin = User.create!(common_attrs.merge(
        username: "admin#{n + 1}",
        email: "admin#{n + 1}@example.com",
        verified_at: Time.current,
        residence_verified_at: Time.current,
        document_number: "1234567#{n}A",
        document_type: 1
      ))
      admin.create_administrator
      Poll::Officer.create!(user: admin)
    end
  end

  desc "populate the default pages manually"
  task pages: :environment do
    load(Rails.root.join("db", "pages.rb"))
  end

  desc "Load SDG content into database"
  task load_sdg: :environment do
    ApplicationLogger.new.info "Adding Sustainable Development Goals content"
    load(Rails.root.join("db", "sdg.rb"))
    WebSection.where(name: "sdg").first_or_create!
  end

  desc "Calculates the TSV column for all polls and legislation processes"
  task calculate_tsv: :environment do
    Poll.find_each(&:calculate_tsvector)
    Legislation::Process.find_each(&:calculate_tsvector)
  end
end
