git stash
git checkout develop

# Build
stack exec blog clean
stack exec blog build

# Switch to master branch
git fetch --all
git checkout -b master --track origin/master

# Overwrite site files
cp -a _site/. .

# Commit & Push
git add -A
git commit -m "Publish."
git push origin master:master

# Restoration
git checkout develop
git branch -D master
git stash pop
