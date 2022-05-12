class PostPrintsController < ApplicationController
  def index
    @analysis_files = collect_file_names
  end

  def analyze
    clear_last_analysis
    clear_pp_files
    f_name = post_prints_csv.original_filename
    f_path = File.join('app', 'post_prints', f_name)
    File.open(f_path, "wb") { |f| f.write(post_prints_csv.read) }
    errored_files = []
    CSV.foreach(f_path, headers: true, encoding: "ISO8859-1:UTF-8", force_quotes: true, quote_char: '"', liberal_parsing: true) do |row|
      sys = system("wget --header 'X-API-Key: #{api_key}' 'ai-s3-authorizer.k8s.libraries.psu.edu/api/v1/#{URI.escape(row['POST_FILE_1_DOC'])}' -P '#{post_prints_directory}'")
      errored_files << row['POST_FILE_1_DOC'] if sys == false
    end
    File.open("#{post_prints_directory}/errors.txt", "wb") { |file| errored_files.each { |row| file << row } }
    system("zip -9 -y -q -j #{analysis_directory}/post-print-analysis-#{DateTime.now.strftime('%FT%T').to_s}.zip #{post_prints_directory}/*")
    clear_pp_files
    redirect_to post_prints_path
  end

  private

    def clear_pp_files
      Dir.foreach(post_prints_directory) do |f|
        fn = File.join(post_prints_directory, f)
        File.delete(fn) if File.exist?(fn) && f != '.' && f != '..'
      end
    end

    def clear_last_analysis
      Dir.foreach(analysis_directory) do |f|
        fn = File.join(analysis_directory, f)
        File.delete(fn) if File.exist?(fn) && f != '.' && f != '..'
      end
    end

    def post_prints_csv
      params.require(:post_print_file)
    end

    def api_key
      Rails.application.config_for(:activity_insight)['s3_bucket']['api_key']
    end

    def post_prints_directory
      "#{Rails.root}/app/post_prints"
    end

    def analysis_directory
      "#{Rails.root}/public/post_prints"
    end

    def collect_file_names
      filenames = []
      Dir.foreach("#{Rails.root}/public/post_prints") do |item|
        next if ['.', '..'].include? item

        filenames << item
      end
      filenames
    end
end
