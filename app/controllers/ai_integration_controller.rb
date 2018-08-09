require 'pure_data/get_pure_ids'
require 'pure_data/pure_populate_db'
require 'pure_data/get_pure_publishers'
require 'pure_data/pure_xml_builder'
require 'osp_data/osp_parser'
require 'osp_data/osp_populate_db'
require 'osp_data/osp_xml_builder'
require 'lionpath_data/lionpath_parser'
require 'lionpath_data/lionpath_populate_db'
require 'lionpath_data/lionpath_xml_builder'
require 'activity_insight/ai_integrate_data'

class AiIntegrationController < ApplicationController

  def osp_integrate
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
  
  def lionpath_integrate
    start = Time.now
    f_name = params[:courses_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:courses_file].read) }
    my_lionpath_populate = LionPathPopulateDB.new(LionPathParser.new(filepath = f_path))
    my_lionpath_populate.format_and_filter
    my_lionpath_populate.populate
    lionpath_integrate = IntegrateData.new(LionPathXMLBuilder.new)
    lionpath_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_s + ' mins')
    File.delete(f_path) if File.exist?(f_path)
    redirect_to ai_integration_path
  end

  def pure_integrate
    start = Time.now
    my_get_pure_ids = GetPureIDs.new
    my_get_pure_ids.call
    my_pure_populate_db = PurePopulateDB.new
    my_pure_populate_db.populate
    my_get_pure_publishers = GetPurePublishers.new
    my_get_pure_publishers.call
    my_integrate = IntegrateData.new(PureXMLBuilder.new)
    my_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_s + ' mins')
    redirect_to ai_integration_path
  end

  def index
  end
end
