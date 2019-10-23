class DestroyCaptchaTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :simple_captcha_data
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
