require "rubygems"
require "json"

branch_to_promote = ARGV[0]

if !File.exist?('.exp-flow')
  puts "In order to use magic merge, you need to have a .exp-flow file with branch mappings"
  exit
end

file = open(".exp-flow")
json = file.read

parsed = JSON.parse(json)

is_the_branch_in_our_list=false
branch_to_promote_into = nil
parsed["Promotion_paths"].each do |from, to|
  if from == branch_to_promote
    is_the_branch_in_our_list = true
    branch_to_promote_into = to
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
puts `git push origin #{branch_to_promote_into}`
if !$?.success?
  puts "something seems to have gone wrong push - stopping"
  exit
end


# TODO - add label making here
