module UniqueDirectory
  def next_unique_directory_name(base, prefix)
    with_lock_on(base) do
      seen = Dir.new(base).grep(/^#{prefix}\d+$/o)
      last = seen.map { |s| s.sub(prefix, '').to_i }.max
      name = prefix + ((last || 0) + 1).to_s.rjust(5, "0")

      FileUtils.mkdir_p(File.join(base, name), :mode => 0755)

      name
    end
  end

  def with_lock_on(base, &block)
    raise "No block given." unless block_given?

    lockfile = File.join(base, "lock")
    FileUtils.touch(lockfile)

    File.open(lockfile) { |fp|
      fp.flock(File::LOCK_EX)
      result = block.call
      fp.flock(File::LOCK_UN)
      result
    }
  end
end
