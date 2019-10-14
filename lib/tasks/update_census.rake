namespace :census do

  desc 'Maintains the user database synchronized with census. Removes verification of users removed from census.'

  task synchronize: :environment do
    index = 1
    User.level_two_or_three_verified.find_each do |user|

      census_api_response = CensusApiCustom.new.call(user.document_type, user.document_number)
      unless census_api_response.valid?

        Mailer.email_removed_from_census(user, user.email, user.document_type).deliver_later
        user.downgrade_verification_level
      end

      index += 1
    end
  end

end
