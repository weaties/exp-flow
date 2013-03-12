

results = `git checkout integration`
puts results
results = `git pull bare integration`
puts results
results = `git merge trunk`
puts results
results = `git push bare`
puts results
