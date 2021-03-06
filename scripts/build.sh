#!/bin/bash

rm -rf public
mkdir public
cp src/index.html public
npx rescript
npx esbuild lib/es6/src/Index.bs.js --entry-names=[name]-[hash] --bundle --minify --outfile=public/app.js
file=$(find public -name 'app*' | sed 's/public\///')
sed -i -e "s/<\/body>/<script src=\"\/$file\"><\/script><\/body>/" public/index.html
