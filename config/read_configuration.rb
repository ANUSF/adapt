require 'java' if defined?(JRUBY_VERSION)

# The body of this module reads configuration parameters from various
# sources and collects them in the constant ADAPT::CONFIG. This code
# is meant to be loaded once during the Rails initialization process.
module ADAPT
  def self.is_blank?(val)
    val.respond_to?(:empty?) ? val.empty? : !val
  end

  # Converts its parameter to an integer.
  def self.make_integer(val)
    if val.is_a? String
      if val.start_with?('0x')
        val.hex
      elsif val.start_with?('0')
        val.oct
      else
        val.to_i
      end
    else
      val
    end
  end

  # Converts its parameter to a boolean (true or false).
  def self.make_boolean(val)
    if val.is_a?(String)
      %w{true yes ok 1}.include? val.downcase
    else
      val && val != 0
    end
  end

  # Normalizes a path value, using a default for empty values, and a
  # base directory for relative paths.
  def self.make_path(val, default, base)
    val = default if is_blank?(val)
    val = val.to_s
    (is_blank?(val) or val == File.expand_path(val)) ? val : File.join(base, val)
  end

  # -- get application defaults
  defaults = YAML::load(File.open(File.join(Rails.root, "config",
                                            "adapt_defaults.yml")))
  config = defaults[Rails.env] || {}
  user_home = Rails.root.to_s

  # -- override with servlet context if any
  if defined?(JRUBY_VERSION) && defined?($servlet_context)
    $servlet_context.get_init_parameter_names.each do |name|
      config[name] = $servlet_context.get_init_parameter(name)
    end
  end

  # -- override with Java system settings
  if defined?(JRUBY_VERSION)
    java.lang.System.getProperties.propertyNames.each do |name|
      if name.start_with?('adapt.') or name.start_with?('assda.')
        config[name] = java.lang.System.getProperty(name)
      end
    end
    tmp = java.lang.System.getProperty('user.home')
    user_home = tmp unless is_blank?(tmp)
  end

  # -- override with runtime environment settings
  ENV.keys.each do |name|
    if name.start_with?('ADAPT') or name.start_with?('ASSDA')
      config[name.downcase.gsub(/_/, '.')] = ENV[name]
    end
    tmp = ENV['HOME']
    user_home = tmp unless is_blank?(tmp)
  end

  # -- handle relative paths
  config['adapt.home'] = make_path(config['adapt.home'],
                                   Rails.root.to_s, user_home)
  config['adapt.asset.path'] = make_path(config['adapt.asset.path'], 'assets',
                                         config['adapt.home'])
  config['adapt.archive.path'] = make_path(config['adapt.archive.path'],
                                           'Archive', config['adapt.asset.path'])
  config['adapt.config.path'] = make_path(config['adapt.config.path'], 'config',
                                         config['adapt.home'])
  config['adapt.db.path'] = make_path(config['adapt.db.path'], '',
                                      config['adapt.home'])

  # -- the default database path depends on the adapter
  if is_blank? config['adapt.db.path']
    adapter = config['adapt.db.adapter']
    config['adapt.db.path'] =
      if %{mysql postgresql}.include?(adapter)
        "adapt_#{Rails.env}"
      else
        suffix = (Rails.env == 'production') ? '' : "_#{Rails.env}"
        File.join(config['adapt.home'], 'db', "db#{suffix}.#{adapter}")
      end
  end

  # -- normalize numerical values
  config['adapt.dir.mode'] = make_integer(config['adapt.dir.mode'])
  config['adapt.file.mode'] = make_integer(config['adapt.file.mode'])

  # -- normalize boolean values
  config['adapt.is.local'] = make_boolean(config['adapt.is.local'])

  # -- make the configuration accessible as a constant
  CONFIG = config
end
