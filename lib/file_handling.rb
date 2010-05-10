module FileHandling
  include LazyEnumerable

  def write_file(data, *path_parts)
    path = File.join(*path_parts)
    make_path(File.dirname(path))
    path = non_conflicting(path)
    File.open(path, "w", ENV['ADAPT_FILE_MODE'].oct) { |fp| fp.write(data) }
    set_ownership(path)
    path
  end

  def read_file(*path_parts)
    path = File.join(*path_parts)
    File.open(path) { |fp| fp.read } if File.exist?(path)
  end

  def next_unique_directory_name(base, prefix, number_length = 5)
    with_lock_on(base) do
      seen = Dir.new(base).grep(/^#{prefix}\d+$/o)
      last = seen.map { |s| s.sub(prefix, '').to_i }.max
      name = prefix + ((last || 0) + 1).to_s.rjust(number_length, "0")
      make_path(File.join(base, name))
      name
    end
  end

  def with_lock_on(base, &block)
    raise "No block given." unless block_given?

    make_path(base)
    File.open(File.join(base, "lock"), 'w+') do |fp|
      begin
        fp.flock(File::LOCK_EX)
        block.call
      ensure
        fp.flock(File::LOCK_UN)
      end
    end
  end

  def non_conflicting(path)
    if !File.exist?(path)
      path
    else
      Stream.new('a', &:next).map { |s|
        path.sub(/((\.[^.]*)?)$/, "-#{s}\\1")
      }.find { |p| !File.exist?(p) }
    end
  end

  def make_path(path)
    dir = File.dirname(path)
    make_path(dir) unless dir == path
    unless File.exist?(path)
      FileUtils.mkdir(path, :mode => ENV['ADAPT_DIR_MODE'].oct)
      set_ownership(path)
    end
  end

  private

  def set_ownership(path)
    user, group = (ENV['ADAPT_FILE_OWNERSHIP'] || '').split('.')
    user = nil if user.blank? or user == "*"
    group = nil if group.blank? or group == "*"
    FileUtils.chown(user, group, path)
  end
end
