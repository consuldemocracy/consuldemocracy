class Attachment < ActiveRecord::Base

  belongs_to :attachable, polymorphic: true

  mount_uploader :file, AttachmentUploader

  validates :file, file_size: { less_than: 5.megabytes }, presence: true
  #validates :attachable_id, presence: true

  def document?
    'pdf'.eql?(file.file.extension.downcase)
  end
end
