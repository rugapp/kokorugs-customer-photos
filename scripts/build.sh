  
#!/bin/bash

rm -rf public
mkdir public
cp src/index.html public
npx rescript
npx esbuild lib/es6/src/Index.bs.js --bundle --minify --outfile=public/app.js
