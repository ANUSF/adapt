Warbler::Config.new do |config|
  config.dirs = %w(app config lib vendor script log tmp db/migrate)

  #config.includes = FileList["db/db_bootstrap.sqlite3"]

  config.excludes = FileList["lib/tasks", "tmp/openids/*"]

  config.java_classes = FileList["java/bin/au/**/*"]

  config.pathmaps.java_classes << "%{java/bin/,}p"

  config.gems += [ "activerecord-jdbcsqlite3-adapter", "jruby-openssl" ]
  
  config.gem_dependencies = true

  config.war_name = "adapt-#{Time.now.strftime("%Y%m%d%H%M%S")}"
end
