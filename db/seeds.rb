# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: "admin", email: "admin@consul.dev", password: "12345678",
                       password_confirmation: "12345678", confirmed_at: Time.current,
                       terms_of_service: "1")
  admin.create_administrator
end

Setting.reset_defaults

WebSection.where(name: "homepage").first_or_create
WebSection.where(name: "debates").first_or_create
WebSection.where(name: "proposals").first_or_create
WebSection.where(name: "budgets").first_or_create
WebSection.where(name: "help_page").first_or_create

# Default custom pages
load Rails.root.join("db", "pages.rb")
