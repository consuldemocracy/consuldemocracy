namespace :emails do

  desc "Sends email digest of proposal notifications to each user"
  task digest: :environment do
    email_digest = EmailDigest.new
    email_digest.create
  end

end
