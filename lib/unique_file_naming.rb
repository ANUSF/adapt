module UniqueFileNaming
  include LazyEnumerable

  def next_unique_directory_name(base, prefix, number_length = 5)
    with_lock_on(base) do
      seen = Dir.new(base).grep(/^#{prefix}\d+$/o)
      last = seen.map { |s| s.sub(prefix, '').to_i }.max
      name = prefix + ((last || 0) + 1).to_s.rjust(number_length, "0")

      FileUtils.mkdir_p(File.join(base, name), :mode => 0755)

      name
    end
  end

  def with_lock_on(base, &block)
    raise "No block given." unless block_given?

    FileUtils.mkdir_p(base, :mode => 0755)
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
end
