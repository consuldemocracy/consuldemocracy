namespace :emails do

  desc "Sends email digest of proposal notifications to each user"
  task digest: :environment do
    User.email_digest.find_each do |user|
      email_digest = EmailDigest.new(user)
      email_digest.deliver
    end
  end

end
