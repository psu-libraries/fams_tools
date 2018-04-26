namespace :lionpath_data do

  desc "Filter and format LionPath data"

  task format: :environment do
    my_lionpath = LionPathFormat.new
    my_lionpath.format
  end

end

