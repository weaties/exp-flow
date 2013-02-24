results = `git checkout master`
puts results
results = `git merge integration`
puts results
results = `git tag -a -m 'a promote' rtw/2013/02/24/2/TODO_AUTO_MATE_THIS`
puts results
results = `git branch -f hf`
puts results
results = `git checkout trunk`
