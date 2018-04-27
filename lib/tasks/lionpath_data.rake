require 'lionpath_format'

namespace :lionpath_data do

  desc "Filter and format LionPath data"

  task format: :environment do
    my_lionpath = LionPathFormat.new
    my_lionpath.format
    my_lionpath.filter_by_user
    my_lionpath.write_results_to_xl
    my_lionpath.write_flagged_to_xl
  end

end

