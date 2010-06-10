module FileHandling
  include LazyEnumerable

  def write_file(data, *path_parts)
    path = File.join(*path_parts)

    with_lock_on(File.dirname(path)) do
      path = non_conflicting(path)
      File.open(path, "w", ADAPT::CONFIG['adapt.file.mode']) do |fp|
        fp.write(data)
      end
      set_ownership(path)
      path
    end
  end

  def read_file(*path_parts)
    path = File.join(*path_parts)
    File.open(path) { |fp| fp.read } if File.exist?(path)
  end

  def next_directory_name(base, prefix, number_length = 5)
    num = if File.exists?(base)
            last = Dir.new(base).grep(/\A#{prefix}\d+\Z/o).max
            last ? last.sub(prefix, '').to_i + 1 : 1
          else
            1
          end
    prefix + num.to_s.rjust(number_length, "0")
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

  def make_path(*path_parts)
    path = File.join(*path_parts)
    dir = File.dirname(path)
    make_path(dir) unless dir == path
    unless File.exist?(path)
      FileUtils.mkdir(path, :mode => ADAPT::CONFIG['adapt.dir.mode'])
      set_ownership(path)
    end
  end

  private

  def set_ownership(path)
    user, group = (ADAPT::CONFIG['adapt.file.ownership'] || '').split('.')
    user = nil if user.blank? or user == "*"
    group = nil if group.blank? or group == "*"
    FileUtils.chown(user, group, path)
  end
end
