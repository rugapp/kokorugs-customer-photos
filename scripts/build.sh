#!/bin/bash

rm -rf public
mkdir public
cp src/index.html public
npx rescript
npx esbuild lib/es6/src/Index.bs.js --entry-names=[name]-[hash] --bundle --minify --outfile=public/app.js
file=$(find public -name 'app*')
file=${file:7:15}
sed -i '' "s/<\/body>/<script src=\"\/$file\"><\/script><\/body>/" public/index.html 
