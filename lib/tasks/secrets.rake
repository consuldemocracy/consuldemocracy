namespace :secrets do
  desc "Add SMTP settings to secrets.yml"
  task smtp: :environment do
    exit if Rails.application.secrets.smtp_settings

    current_settings = {
      "mailer_delivery_method" => ActionMailer::Base.delivery_method.to_s,
      "smtp_settings"          => ActionMailer::Base.smtp_settings.stringify_keys
    }

    secrets = Rails.application.config.paths["config/secrets"].first
    stream = Psych.parse_stream(File.read(secrets))
    nodes = stream.children.first.children.first

    environment_index = nodes.children.index do |child|
      child.is_a?(Psych::Nodes::Scalar) && child.value == Rails.env
    end

    nodes.children[environment_index + 1].children.push(*Psych.parse(current_settings.to_yaml).children.first.children)

    File.open(secrets, "w") { |file| file.write stream.to_yaml }
  end
end
