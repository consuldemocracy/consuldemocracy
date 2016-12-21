class SandboxController < ApplicationController
  skip_authorization_check

  def index
    @templates = Dir.glob(Rails.root.join('app/views/sandbox/*.html.erb').to_s).map do |filename|
      filename = File.basename(filename, File.extname(filename))
      filename unless filename.starts_with?('_') || filename == 'index.html'
    end.compact
  end

  def show
    if params[:template].index('.') # CVE-2014-0130
      render :action => "index"
    elsif lookup_context.exists?("sandbox/#{params[:template]}")
      if params[:template] == "index"
        render :action => "index"
      else
        render "sandbox/#{params[:template]}"
      end

    elsif lookup_context.exists?("sandbox/#{params[:template]}/index")
      render "sandbox/#{params[:template]}/index"
    else
      render :action => "index"
    end
  end
end
