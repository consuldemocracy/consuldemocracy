namespace :newsletter do

  desc 'Renders and sends newsletter to users who checked preference "newsletter"'


  task :email, [:subject, :template_name, :image_file_path] => [:environment] do |t, args|

    subject = args[:subject]
    template_name = args[:template_name]
    image_file_path = args[:image_file_path]
    index = 1
    success_messages = 0

    logger = Logger.new(Rails.root.join('log', 'newsletter.log'))
    users = User.newsletter.order(:created_at)

    logger.info "[BEGIN] total_messages:#{users.count} subject '#{subject}', template: '#{template_name}', image: #{image_file_path}"

    users.find_each do |user|
      log_line = "[SENDING] index: #{index}, user: #{user.email}"
      begin

        sleep 2 # Wait until send next message

        Mailer.email_newsletter(user, user.email, subject, template_name, image_file_path).deliver_later
        logger.info log_line
        success_messages += 1

      rescue Exception => ex

        logger.error log_line
        logger.error ex.message
        logger.error ex.backtrace.join("\n")
      end
      index += 1
    end

    logger.info "[FINISH] total_messages:#{users.count} success: #{success_messages}"
  end

end
