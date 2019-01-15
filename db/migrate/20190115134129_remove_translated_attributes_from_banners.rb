class RemoveTranslatedAttributesFromBanners < ActiveRecord::Migration
  def change
    remove_columns :banners, :title, :description
  end
end
