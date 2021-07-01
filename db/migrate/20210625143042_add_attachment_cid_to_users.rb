class AddAttachmentCidToUsers < ActiveRecord::Migration[5.2]
  def self.up
    change_table :users do |t|
      t.attachment :cid
    end
  end

  def self.down
    remove_attachment :users, :cid
  end
end
