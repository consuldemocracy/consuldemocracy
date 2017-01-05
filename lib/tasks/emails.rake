namespace :emails do

  desc "Sends email digest of proposal notifications to each user"
  task digest: :environment do
    User.email_digest.find_each do |user|
      email_digest = EmailDigest.new(user)
      begin
        email_digest.deliver
        email_digest.mark_as_emailed
      rescue
        user.increment_counter(:failed_email_digests_count)
        user.save
      end
    end
  end

end
