class ComQualityIntegrateJob < ApplicationJob
  # When using rake task, _user_uploaded must = false
  # This will initiate the bash script to pull the necessary file
  # instead of uploaded file
  def integrate(params, _user_uploaded = true)
    f_path = create_tmp_file(params, _user_uploaded)
    populate_course_data(f_path)
    errors = integrate_course_data(params[:target])
    File.delete(f_path) if File.exist?(f_path)
    errors
  end

  private

  def create_tmp_file(params, user_uploaded)
    if user_uploaded == true
      f_path = File.join('app', 'parsing_files', 'ume_faculty_quality.csv')
      File.binwrite(f_path, params[:com_quality_file].read)
      f_path
    else
      # Running bash script to grab Com files
      `#{Rails.root}/bin/com-effort-quality.sh`
      File.join('app', 'parsing_files', 'ume_faculty_quality.csv')
    end
  end

  def populate_course_data(f_path)
    com = com_populate_obj(f_path)
    com.populate
  end

  def com_populate_obj(f_path)
    ComData::ComQualityPopulateDb.new(ComData::ComParser.new(f_path))
  end

  def integrate_course_data(target)
    com_integrate_obj(target).integrate
  end

  def com_integrate_obj(target)
    ActivityInsight::IntegrateData.new(ComData::ComQualityXmlBuilder.new.xmls_enumerator_quality, target, :post)
  end

  def name
    'College of Medicine Integration: Quality'
  end
end
