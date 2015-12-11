# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@madrid.es', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.now, terms_of_service: "1")
  admin.create_administrator
end
