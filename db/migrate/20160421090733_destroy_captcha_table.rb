class DestroyCaptchaTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :simple_captcha_data
  end
end
