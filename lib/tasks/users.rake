namespace :users do

  desc "Recalculates all the failed census calls counters for users"
  task count_failed_census_calls: :environment do
    User.find_each{ |user| User.reset_counters(user.id, :failed_census_calls)}
  end

  desc "Assigns official level to users with the officials' email domain"
  task check_for_official_emails: :environment do
    domain = Setting['email_domain_for_officials']

    # We end the task if there is no email domain configured
    if !domain.blank?
      # We filter the mail addresses with SQL to speed up the process
      # The real check will be done by check_if_official_email, however.
      User.where('official_level = 0 and email like ?', "%#{domain}").find_each do |user|
        if user.has_official_email?
          user.add_official_position! (Setting['official_level_1_name']), 1
          puts "#{user.username} (#{user.email}) is now a level-1 official."
        end
      end
    end
  end

  desc "Associates a geozone to each user who doesn't have it already but has validated his residence using the census API"
  task assign_geozones: :environment do
    User.residence_verified.where(geozone_id: nil).find_each do |u|
      begin
        response = CensusApi.new.call(u.document_type, u.document_number)
        if response.valid?
          u.geozone = Geozone.where(census_code: response.district_code).first
          u.save
          print "."
        else
          print "X"
        end
      rescue
        puts "Could not assign geozone for user: #{u.id}"
      end
    end
  end

  desc "Associates demographic information to users"
  task assign_demographic: :environment do
    User.residence_verified.where(genre: nil).find_each do |u|
      begin
        response = CensusApi.new.call(u.document_type, u.document_number)
        if response.valid?
          u.genre = response.genre == 'Varón' ? 'male' : 'female'
          u.date_of_birth = response.date_of_birth.to_datetime
          u.save
          print "."
        else
          print "X"
        end
      rescue
        puts "Could not assign genre/dob for user: #{u.id}"
      end
    end
  end

end
