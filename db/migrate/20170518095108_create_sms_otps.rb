class CreateSmsOtps < ActiveRecord::Migration
  def change
    create_table :sms_otps do |t|
      t.string :phone_number, index: true, null: false, unique: true
      t.string :confirmation_code, null: false

      t.timestamps null: false
    end

    reversible do |dir|

      dir.up do

        User.where.not(unconfirmed_phone: nil).where.not(sms_confirmation_code: nil).where(confirmed_phone: nil).each do |user|

          normalized = PhonyRails.normalize_number(user.unconfirmed_phone, default_country_code: 'ES',  strict: true)
          SmsOtp.create(phone_number: normalized, confirmation_code: user.sms_confirmation_code)
        end
      end
    end
  end
end
