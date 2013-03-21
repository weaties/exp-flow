require "rubygems"
require "json"
require "logger"
require "date"
require "time"

log = Logger.new(STDOUT)
log.level=Logger::DEBUG
log.datetime_format = "%Y-%M-%D:%H:%S"
log.info("staring Magic Merge")
branch_to_promote = ARGV[0]

log.info("Promoting #{branch_to_promote}")


if !File.exist?('.exp-flow')
  puts "In order to use magic merge, you need to have a .exp-flow file with branch mappings"
  exit
end

file = open(".exp-flow")
json = file.read

parsed = JSON.parse(json)

is_the_branch_in_our_list=false
branch_to_promote_into = nil
label_base_to_create = nil
parsed["Promotion_paths"].each do |from, to, label_base|
  if from == branch_to_promote
    is_the_branch_in_our_list = true
    branch_to_promote_into = to
    label_base_to_create= label_base
  end
end
if !is_the_branch_in_our_list
  puts "you asked to promote #{branch_to_promote} but it is not in the list of branches we are managing"
  parsed["Promotion_paths"].each { |from, to| puts "#{from} ==> #{to}"}
  exit
end
puts "we are going to promote #{branch_to_promote} into #{branch_to_promote_into}"
puts `git fetch origin`
puts `git checkout #{branch_to_promote_into}`
puts `git pull`
puts `git pull origin #{branch_to_promote_into}`
puts `git merge origin/#{branch_to_promote}`
if !$?.success?
  puts "something seems to have gone wrong with merge- stopping"
  exit
end
if label_base_to_create != ""
  tag_name = label_base_to_create + "/#{Time.now.utc.iso8601.gsub("-","/").gsub(":","/").gsub("T","/T")}"
  puts `git tag -a -m "Promoting #{branch_to_promote} into #{branch_to_promote_into} by #{ENV["USER"]}" #{tag_name}`
  puts `git push origin #{tag_name}`
end

puts `git push origin #{branch_to_promote_into}`
if !$?.success?
  puts "something seems to have gone wrong push - stopping"
  exit
end

