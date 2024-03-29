class DeleteRecordsJob < ApplicationJob
  def integrate(params, _user_uploaded = true)
    f_name = 'delete.csv'
    f_path = File.join('app', 'parsing_files', f_name)
    File.binwrite(f_path, params[:ids_file].read)
    delete_records = ActivityInsight::DeleteRecords.new(params[:resource], params[:target])
    errors = delete_records.delete
    File.delete(f_path) if File.exist?(f_path)
    errors
  end

  private

  def name
    'Delete Records'
  end
end
