include FileHandling
with_lock_on('xxx') do
  puts 'Type something:'
  gets
end
puts 'Done!'
