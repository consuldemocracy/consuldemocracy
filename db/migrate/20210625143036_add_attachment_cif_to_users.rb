class AddAttachmentCifToUsers < ActiveRecord::Migration[5.2]
  def self.up
    change_table :users do |t|
      t.attachment :cif
    end
  end

  def self.down
    remove_attachment :users, :cif
  end
end
