class RemovePaperclipColumns < ActiveRecord::Migration[6.1]
  def change
    change_table :images do |t|
      t.remove :attachment_file_name, type: :string
      t.remove :attachment_content_type, type: :string
      t.remove :attachment_file_size, type: :bigint
      t.remove :attachment_updated_at, type: :datetime
    end

    change_table :documents do |t|
      t.remove :attachment_file_name, type: :string
      t.remove :attachment_content_type, type: :string
      t.remove :attachment_file_size, type: :bigint
      t.remove :attachment_updated_at, type: :datetime
    end
  end
end
