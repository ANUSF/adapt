module FileHandling
  include LazyEnumerable

  def write_file(data, base, *path_parts)
    make_parent(base, *path_parts)
    path = File.expand_path(File.join(base, *path_parts))

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

  def create_unique_id_and_directory(base, prefix, range, number_length = 5)
    with_lock_on(base) do
      existing = Dir.new(base).grep(/\A#{prefix}\d+\Z/o).map { |name|
        name.sub(/\A#{prefix}/o, '').to_i
      }.select { |n| range.include? n }
      num = (existing.max || 0) + 1
      raise 'No more numbers available.' unless range.include? num
      name = prefix + num.to_s.rjust(number_length, "0")
      make_directory(base, name)
      name
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

  def make_directory(base, *path_parts)
    make_parent(base, *path_parts)
    path = File.expand_path(File.join(base, *path_parts))

    unless File.exist?(path)
      FileUtils.mkdir(path, :mode => ADAPT::CONFIG['adapt.dir.mode'])
      set_ownership(path)
    end
  end

  private

  def with_lock_on(base, &block)
    raise "No block given." unless block_given?

    lock_file = File.join(base, 'lock')
    fp = create_lock_file(lock_file)

    begin
      fp.flock(File::LOCK_EX)
      block.call
    ensure
      fp.close
      File.unlink(lock_file)
    end
  end

  def create_lock_file(lock_file, retries = 12)
    retries.times do
      begin
        return File.open(lock_file, File::CREAT|File::EXCL|File::WRONLY, 0600)
      rescue Errno::EEXIST => ex
        sleep 5
      end
    end
    raise 'Could not obtain directory access.'
  end

  def make_parent(base, *path_parts)
    rest = File.join(*path_parts)
    up = File.dirname(rest)
    path = File.expand_path(File.join(base, rest))
    dir = File.expand_path(File.join(base, up))
    make_directory(base, up) unless dir.starts_with?(path)
  end

  def set_ownership(path)
    user, group = (ADAPT::CONFIG['adapt.file.ownership'] || '').split('.')
    user = nil if user.blank? or user == "*"
    group = nil if group.blank? or group == "*"
    FileUtils.chown(user, group, path)
  end
end
