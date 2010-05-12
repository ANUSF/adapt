require 'java'

# -- we run this before Rails does its monkey-patching, and we want 'blank?'
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

# The body of this module reads configuration parameters from various
# sources and collects them in the constant ADAPT::CONFIG. This code
# is meant to be loaded once during the Rails initialization process.
module ADAPT
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
    val = default if val.blank?
    (val.blank? or val == File.expand_path(val)) ? val : File.join(base, val)
  end

  # -- get application defaults
  defaults = YAML::load(File.open(File.join(RAILS_ROOT, "config",
                                            "adapt_defaults.yml")))
  config = defaults[RAILS_ENV] || {}
  user_home = RAILS_ROOT

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
    user_home = tmp unless tmp.blank?
  end

  # -- override with runimte environment settings
  ENV.keys.each do |name|
    if name.start_with?('ADAPT') or name.start_with?('ASSDA')
      config[name.downcase.gsub(/_/, '.')] = ENV[name]
    end
    tmp = ENV['HOME']
    user_home = tmp unless tmp.blank?
  end

  # -- handle relative paths
  config['adapt.home'] = make_path(config['adapt.home'], RAILS_ROOT, user_home)
  config['adapt.asset.path'] = make_path(config['adapt.asset.path'], 'assets',
                                         config['adapt.home'])
  config['adapt.db.path'] = make_path(config['adapt.db.path'], '',
                                      config['adapt.home'])

  # -- the default database path depends on the adapter
  if config['adapt.db.path'].blank?
    adapter = config['adapt.db.adapter']
    config['adapt.db.path'] =
      if %{mysql postgresql}.include?(adapter)
        "adapt_#{RAILS_ENV}"
      else
        suffix = (RAILS_ENV == 'production') ? '' : "_#{RAILS_ENV}"
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
