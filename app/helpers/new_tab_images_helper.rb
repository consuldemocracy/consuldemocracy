module NewTabImagesHelper
  def new_tab_render_image(image, version, show_caption = true, open_in_new_tab = false)
    render "images/new_tab_image", image: image,
                           version: (version if image.persisted?),
                           show_caption: show_caption,
                           open_in_new_tab: open_in_new_tab
  end
end
