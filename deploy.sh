set -xe
rm -rf _site
JEKYLL_ENV=production bundle exec jekyll build

cd _site
git init
git checkout -b gh-pages
git add .
git commit -m "Deploy to GitHub Pages"
git remote add origin git@github.com:ninhlv-9984/ninhlv-9984.github.io.git
git push -f origin gh-pages
