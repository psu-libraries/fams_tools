class LionpathIntegrateJob < ApplicationJob
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
      f_name = params[:courses_file].original_filename
      f_path = File.join('app', 'parsing_files', f_name)
      File.binwrite(f_path, params[:courses_file].read)
      f_path
    else
      # Running bash script to grab lionpath files
      `#{Rails.root}/bin/courses-taught.sh`
      File.join('app', 'parsing_files', 'courses_taught.csv')
    end
  end

  def populate_course_data(f_path)
    lionpath = lionpath_populate_obj(f_path)
    lionpath.format_and_filter
    lionpath.populate
  end

  def lionpath_populate_obj(f_path)
    LionpathData::LionpathPopulateDb.new(LionpathData::LionpathParser.new(f_path))
  end

  def integrate_course_data(target)
    lionpath_integrate_obj(target).integrate
  end

  def lionpath_integrate_obj(target)
    ActivityInsight::IntegrateData.new(LionpathData::LionpathXmlBuilder.new.xmls_enumerator, target, :post)
  end

  def name
    'Courses Taught Integration'
  end
end
