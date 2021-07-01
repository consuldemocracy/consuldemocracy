class AddAttachmentConstanciaToUsers < ActiveRecord::Migration[5.2]
  def self.up
    change_table :users do |t|
      t.attachment :constancia
    end
  end

  def self.down
    remove_attachment :users, :constancia
  end
end
