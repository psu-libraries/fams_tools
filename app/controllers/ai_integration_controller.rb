require 'osp_data/osp_parser'
require 'osp_data/osp_populate_db'
require 'osp_data/osp_xml_builder'
require 'activity_insight/ai_integrate_data'

class AiIntegrationController < ApplicationController

  def integrate
    start = Time.now
    f_name = params[:congrant_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:congrant_file].read) }
    my_populate = OspPopulateDB.new(OspParser.new(file_path = f_path))
    my_populate.format_and_filter
    my_populate.populate
    my_integrate = IntegrateData.new(OspXMLBuilder.new)
    my_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_s + ' mins')
    File.delete(f_path) if File.exist?(f_path)
    redirect_to ai_integration_path
  end

  def index
  end
end
