require 'rexml/document'
require 'rexml/xpath'

class Admin::PostcodesController < Admin::BaseController
  respond_to :html

  load_and_authorize_resource

  def index
    @postcodes = Postcode.all.order(Arel.sql("UPPER(postcode)")).page(params[:page]).per(10)
  end

  def new
  end

  def ncsv
    @postcodes = Postcode.all
    respond_to do |format|
      format.html { render :ncsv }
      format.csv { render :ncsv, formats: [:csv] }
    end
  end

  def process_csv
    uploaded_file = params[:file]
    expected_headers = ["postcode", "ward", "geozone"]

    if uploaded_file.nil?
      @error_msg = "Please select a CSV file."
      render :ncsv
    else
      file_path = uploaded_file.path
      if File.extname(file_path) == ".csv" && CSV.read(file_path, headers: true).headers == expected_headers
        @rejected_entries, @accepted_entries = postcode_validation(file_path)
        render :ncsv_review
      else
        @error_msg = "Invalid CSV file format. Please make sure the file contains the required headers."
        render :ncsv
      end
    end
  end

  def ncsv_review
  end

  def edit
  end

  def create
    @postcode = Postcode.new(postcode_params)
    if validate_and_save_postcode(@postcode)
      redirect_to admin_postcodes_path
    else
      render :new
    end
  end

  def update
   @postcode.assign_attributes(postcode_params)

    if validate_and_save_postcode(@postcode)
      redirect_to admin_postcodes_path, notice: "Postcode updated successfully."
    else
      render :edit
    end
  end
  
   def destroy
    if @postcode.safe_to_destroy?
      @postcode.destroy!
      redirect_to admin_postcodes_path, notice: t("admin.postcodes.delete.success")
    else
      redirect_to admin_postcodes_path, flash: { error: t("admin.postcodes.delete.error") }
    end
  end



  private

  def validate_and_save_postcode(postcode)
    if postcode.valid? && valid_postcode_format?(postcode.postcode)
      if postcode.save
      flash[:notice] = "Postcode saved successfully."
      return true
    else
      @error_msg = "Invalid postcode format."
      return false
    end
    else
    flash[:alert] = "Invalid postcode format."
    return false
  end
  end

  def valid_postcode_format?(postcode)
    puts postcode
    territory_id = find_territory_id(postcode)
    puts territory_id
    return false unless territory_id

    regex_pattern = retrieve_regex_pattern(territory_id)
    puts "getting regex"
    puts regex_pattern
    return false unless regex_pattern

    postcode.match?(regex_pattern)
  end
  
  
  def find_territory_id(postcode)
    # Logic to find the territory ID for the given postcode
    # This method can be implemented based on your application's requirements
    # For example, you could use a lookup table or an external service to determine the territory ID
    # Here, we assume a placeholder method that always returns "GB" (United Kingdom)
    "GB"
  end

  def retrieve_regex_pattern(territory_id)
    xml_file = File.new("lib/tasks/postcodes.xml")
    xml_doc = REXML::Document.new(xml_file)

    regex_patterns = {}
    REXML::XPath.each(xml_doc, "//postCodeRegex") do |element|
      regex_patterns[element.attributes["territoryId"]] = Regexp.new(element.text)
    end

    regex_patterns[territory_id]
  end


  def postcode_validation(file_path)
    xml_file = File.new("lib/tasks/postcodes.xml")
    xml_doc = REXML::Document.new(xml_file)

    rejected_entries = []
    accepted_entries = []

    regex_patterns = {}
    REXML::XPath.each(xml_doc, "//postCodeRegex") do |element|
      territory_id = element.attributes["territoryId"]
      regex_patterns[territory_id] = Regexp.new(element.text)
    end

    CSV.foreach(file_path, headers: true) do |row|
      next unless row["ward"].present? && row["postcode"].present?

      ward = row["ward"].strip
      postcode = row["postcode"].delete(' ').upcase

      if !regex_patterns.any? { |_, pattern| postcode =~ pattern }
        row << "Error: Invalid postcode"
        rejected_entries << row
      elsif postcode.length > 10
        row << "Error: Postcode too long"
        rejected_entries << row
      elsif Postcode.exists?(postcode: postcode)
        row << "Error: Postcode already exists"
        rejected_entries << row
      else
        geozone = Geozone.find_or_create_by!(name: ward)
        Postcode.create!(postcode: postcode, ward: ward, geozone_id: geozone.id)
        accepted_entries << row
      end
    end
    return [rejected_entries, accepted_entries]
  end

  def postcode_params
    params.require(:postcode).permit(:postcode, :ward, :geozone_id)
  end
end
