if Rails.env.test?
  Rails.application.routes.default_url_options = { host: 'test' }
elsif Rails.env.development?
  Rails.application.routes.default_url_options = { host: 'localhost', port: 3000 }
else
  Rails.application.routes.default_url_options = { host: Rails.application.secrets.server_name }
end