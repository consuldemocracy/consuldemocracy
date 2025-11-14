class CreateNewsletterRecipients < ActiveRecord::Migration[7.1]
  def change
    create_table :newsletter_recipients do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.timestamp :confirmed_at
      t.boolean :active

      t.timestamps
    end

    add_index :newsletter_recipients, :email, unique: true
    add_index :newsletter_recipients, :token, unique: true
    add_index :newsletter_recipients, :active
    add_index :newsletter_recipients, :confirmed_at,
              where: "active = true AND confirmed_at IS NOT NULL",
              name: :index_newsletter_recipients_on_active_confirmed
  end
end
