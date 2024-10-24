Rails.application.reloader.to_prepare do
  ActiveStorage::DirectUploadsController.class_eval do
    def create
      head :unauthorized
    end
  end

  ActiveStorage::DiskController.class_eval do
    def update
      head :unauthorized
    end
  end
end
