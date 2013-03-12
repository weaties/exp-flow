require 'time'
results = `git fetch bare`
puts results
results = `git checkout integration`
puts results
results = `git merge bare/integration`
puts results
results = `git checkout master`
puts results
results = `git merge bare/master`
puts results
results = `git merge integration`
puts results
tagtime = Time.now.utc.iso8601.gsub("-","/").gsub(":","-").gsub("T","/T")
results = `git tag -a -m 'a promote' rtw/#{tagtime}`
puts results
results = `git branch -f hf`
puts results
results = `git checkout trunk`
puts results
results = `git merge bare/trunk`
puts results
results = `git push bare --all`
puts results

