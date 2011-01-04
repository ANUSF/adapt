# Remove all stored mail deliveries
Before { ActionMailer::Base.deliveries.clear }

# Ensure a pristine assets directory for each scenario
Before do
  asset_path = ADAPT::CONFIG['adapt.asset.path']
  %w{Archive Submission Temporary}.each do |s|
    dirname = File.join(asset_path, s)
    FileUtils.mkpath(dirname)
    system("rm -rf #{dirname}/*")
  end
end
