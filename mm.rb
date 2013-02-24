print "hello world!\n"
results = `git checkout integration`
puts results
results = `git merge master`
puts results
results = `git checkout trunk`
puts results
results = `git merge integration`
puts results
