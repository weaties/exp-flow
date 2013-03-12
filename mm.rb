print "hello world!\n"
results = `git fetch bare`
puts results
results = `git checkout master`
puts results
results = `git merge bare/master`
puts results
results = `git checkout integration`
puts results
results = `git merge bare/integration`
puts results
results = `git merge master`
puts results
results = `git push bare integration`
puts results
results = `git checkout trunk`
puts results
results = `git merge bare/trunk`
puts results
results = `git merge integration`
puts results
results = `git push bare trunk`
puts results
