class PostPrintsController < ApplicationController
  def index
    @analysis_files = collect_file_names
  end

  def analyze
    PostPrintAnalyzer.new(post_prints_csv).analyze
    redirect_to post_prints_path
  end

  private

    def post_prints_csv
      params.require(:post_print_file)
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
