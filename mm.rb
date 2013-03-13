require 'rubygems'
require 'json'
require 'Open3'

if !File.exist?('.exp-flow')
  puts "In order to use automatic merge tool for expweb, you need to have a .exp-flow file, which has a 'Promotion_paths'  section in it."
  exit 
end

file = open(".exp-flow")
json = file.read

parsed = JSON.parse(json)

puts `git fetch`
parsed["Promotion_paths"].each do |to, from|
  puts "Doing the magic merge from #{from} to #{to}"
  puts `git checkout #{from}`
  puts `git pull`
  puts `git checkout #{to}`
  puts `git merge #{from}`
  if !$?.success?
    puts "something has gone wrong, we should send mail, but we will stop instead"
    exit
  end
  puts `git push origin #{to}`
  if !$?.success?
    puts "something has gone wrong pushing to bare, going to stop, should send mail"
    exit
  end
end

