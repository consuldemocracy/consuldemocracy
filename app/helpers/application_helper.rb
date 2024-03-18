module ApplicationHelper
  # if current path is /debates current_path_with_query_params(foo: "bar") returns /debates?foo=bar
  # notice: if query_params have a param which also exist in current path,
  # it "overrides" (query_params is merged last)
  def current_path_with_query_params(query_parameters)
    url_for(request.query_parameters.merge(query_parameters).merge(only_path: true))
  end

  def rtl?(locale = I18n.locale)
    %i[ar fa he].include?(locale)
  end

  def markdown(text, **render_options)
    MarkdownConverter.new(text, **render_options).render
  end

  def wysiwyg(text)
    WYSIWYGSanitizer.new.sanitize(text)
  end

  def author_of?(authorable, user)
    return false if authorable.blank? || user.blank?

    authorable.author_id == user.id
  end

  def back_link_to(destination = :back, text = t("shared.back"))
    link_to destination, class: "back" do
      tag.span(class: "icon-angle-left") + text
    end
  end

  def new_window_link_to(text, path, **options)
    link_to text, path, { target: "_blank", title: t("shared.target_blank") }.merge(options)
  end

  def image_path_for(filename)
    image = SiteCustomization::Image.image_for(filename)

    if image
      polymorphic_path(image)
    elsif AssetFinder.find_asset(File.join(Tenant.subfolder_path, filename))
      File.join(Tenant.subfolder_path, filename)
    else
      filename
    end
  end

  def content_block(name, locale = I18n.locale)
    SiteCustomization::ContentBlock.block_for(name, locale)
  end

  def self.asset_data_base64(path)
    asset = (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application))
            .find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  def render_custom_partial(partial_name)
    controller_action = @virtual_path.split("/").last
    custom_partial_path = "custom/#{@virtual_path.remove(controller_action)}#{partial_name}"
    render custom_partial_path if lookup_context.exists?(custom_partial_path, [], true)
  end

  def management_controller?
    controller.class.to_s.include?("Management")
  end
end
