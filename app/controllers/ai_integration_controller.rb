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
require 'activity_insight/ai_get_user_data'
require 'activity_insight/ai_manage_duplicates'

class AiIntegrationController < ApplicationController
  before_action :load_psu_users, only: [:osp_integrate, :lionpath_integrate, :pure_integrate]

  def osp_integrate
    start = Time.now
    f_name = params[:congrant_file].original_filename
    f_path = File.join('app', 'parsing_files', f_name)
    File.open(f_path, "wb") { |f| f.write(params[:congrant_file].read) }
    backup_name = params[:ai_backup_file].original_filename
    backup_path = File.join('app', 'parsing_files', backup_name)
    File.open(backup_path, "wb") { |f| f.write(params[:ai_backup_file].read) }
    my_populate = OspPopulateDB.new(OspParser.new(osp_path = f_path, backup_path = backup_path))
    my_populate.format_and_filter
    my_populate.populate
    my_remove_system_dups = RemoveSystemDups.new(filepath = backup_path)
    my_remove_system_dups.call
    my_integrate = IntegrateData.new(OspXMLBuilder.new)
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    File.delete(backup_path) if File.exist?(backup_path)
    flash[:notice] = "Integration completed in #{@time}."
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
    @errors = lionpath_integrate.integrate
    finish = Time.now
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    File.delete(f_path) if File.exist?(f_path)
    flash[:notice] = "Integration completed in #{@time}."
    flash[:errors] = @errors
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
    @time = (((finish - start)/60).to_i.to_s + ' minutes')
    flash[:notice] = "Integration completed in #{@time}."
    redirect_to ai_integration_path
  end

  def index
  end

  private

  def load_psu_users
    psu_users_name = params[:psu_users_file].original_filename
    psu_users_path = File.join('app', 'parsing_files', psu_users_name)
    File.open(psu_users_path, "wb") { |f| f.write(params[:psu_users_file].read) }
    my_get_user_data = GetUserData.new(psu_users_path)
    my_get_user_data.call
    File.delete(psu_users_path) if File.exist?(psu_users_path)
  end
end
