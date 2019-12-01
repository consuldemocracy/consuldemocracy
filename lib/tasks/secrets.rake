namespace :secrets do
  desc "Add SMTP, SSL and delay jobs settings to secrets.yml"
  task smtp_ssl_and_delay_jobs: :environment do
    current_settings = {
      "mailer_delivery_method" => ActionMailer::Base.delivery_method,
      "smtp_settings"          => ActionMailer::Base.smtp_settings,
      "force_ssl"              => Rails.application.config.force_ssl,
      "delay_jobs"             => Delayed::Worker.delay_jobs
    }

    settings_to_add = current_settings.select do |name, _|
      Rails.application.secrets[name].nil?
    end

    exit if settings_to_add.empty?

    secrets = Rails.application.config.paths["config/secrets"].first
    stream = Psych.parse_stream(File.read(secrets))
    nodes = stream.children.first.children.first

    environment_index = nodes.children.index do |child|
      child.is_a?(Psych::Nodes::Scalar) && child.value == Rails.env
    end

    nodes.children[environment_index + 1].children.push(*Psych.parse(settings_to_add.to_yaml).children.first.children)

    File.open(secrets, "w") { |file| file.write stream.to_yaml }
  end
end
