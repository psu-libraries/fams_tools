class LionpathIntegrateJob < ApplicationJob
  # When using rake task, file_exist must = true
  # This will use existing file 'app/parsing_files/courses_taught.csv'
  # instead of uploaded file
  def integrate(params, _file_exist = false)
    f_path = create_tmp_file(params, _file_exist)
    populate_course_data(f_path)
    errors = integrate_course_data(params[:target])
    File.delete(f_path) if File.exist?(f_path)
    errors
  end

  private

  def create_tmp_file(params, file_exist)
    if file_exist == false
      f_name = params[:courses_file].original_filename
      f_path = File.join('app', 'parsing_files', f_name)
      File.open(f_path, 'wb') { |f| f.write(params[:courses_file].read) }
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
    LionPathPopulateDB.new(LionPathParser.new(f_path))
  end

  def integrate_course_data(target)
    lionpath_integrate_obj(target).integrate
  end

  def lionpath_integrate_obj(target)
    IntegrateData.new(LionPathXMLBuilder.new.xmls_enumerator, target, :post)
  end

  def name
    'Courses Taught Integration'
  end
end
