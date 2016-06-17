#cat *.coffee | coffee -c -b --stdio > Prism.js
coffee --watch --bare --join Prism.js --compile *.coffee
