RSpec.configure do |config|
  config.before(:each, :type => :acceptance) do
    # Remove all stored mail deliveries
    ActionMailer::Base.deliveries.clear

    # Ensure a pristine assets directory for each scenario
    asset_path = ADAPT::CONFIG['adapt.asset.path']
    %w{Archive Submission Temporary}.each do |s|
      dirname = File.join(asset_path, s)
      FileUtils.mkpath(dirname)
      system("rm -rf #{dirname}/*")
    end
  end
end
