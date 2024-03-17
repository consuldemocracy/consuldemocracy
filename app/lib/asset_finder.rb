class AssetFinder
  def self.find_asset(path)
    if Rails.application.assets
      Rails.application.assets.find_asset(path)
    else
      Rails.application.assets_manifest.assets[path]
    end
  end
end
