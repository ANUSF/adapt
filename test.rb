include FileHandling

puts 'Trying to obtain lock...'
with_lock_on('xxx') do
  puts 'Lock obtained! Press return to continue:'
  gets
end
puts 'Lock released!'
