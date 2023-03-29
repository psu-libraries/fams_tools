class YearlyIntegrateJob < ApplicationJob

    def integrate(params, _user_uploaded = true)
      f_name = params[:yearly_file].original_filename
      f_path = File.join('app', 'parsing_files', f_name)
      File.open(f_path, "wb") { |f| f.write(params[:yearly_file].read) }
      yearly_importer = YearlyData::ImportYearlyData.new(f_path)
      yearly_importer.import
      yearly_xml_builder = YearlyData::YearlyXmlBuilder.new.xmls_enumerator
      yearly_integration = ActivityInsight::IntegrateData.new(yearly_xml_builder, params[:target], :post)
      errors = yearly_integration.integrate
      File.delete(f_path) if File.exist?(f_path)
      errors
    end
  
    private
  
    def name
      'Yearly Integration'
    end
  end
  