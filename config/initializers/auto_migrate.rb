# -- make sure a directory exists for the database file
#    (so that Rails can create the file from scratch if necessary)
FileUtils.mkdir_p(File.dirname(ADAPT::CONFIG['adapt.db.path']), :mode => 0750)

# -- automatically migrate the database on startup
ActiveRecord::Migrator.migrate(File.join(Rails.root, "db", "migrate"))
