namespace :timespace_cleanup do
  desc 'cleanup dates'
  task cleanup: :environment do
    ActiveRecord::Base.connection.execute("INSERT INTO schema_migrations (version) VALUES ('20180503142012');")
    ActiveRecord::Base.connection.execute("INSERT INTO schema_migrations (version) VALUES ('20180502122112');")
    ActiveRecord::Base.connection.execute("DELETE FROM schema_migrations WHERE version = '2018050314201234';")
    ActiveRecord::Base.connection.execute("DELETE FROM schema_migrations WHERE version = '2018050212211234';")
  end
end
