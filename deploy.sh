#!/bin/bash

rm -rf /tmp/ext
cp -rL ext /tmp/ext

find /tmp/ext -iname '*.js.map' -type f -print | xargs /bin/rm -f
find /tmp/ext -iname '*.coffee' -type f -print | xargs /bin/rm -f

#find /tmp/ext -iname '*.js' -type f -print -exec bash -c 'ccjs {} --compilation_level=ADVANCED_OPTIMIZATIONS > {}.new' \;
/usr/local/bin/uglifyjs --compress "drop_console" --mangle "sort,toplevel,eval" --screw-ie8 -- /tmp/ext/page/js/{angular.min.js,ui-bootstrap-tpls.min.js,angular-cookies.min.js,angular-ui-router.min.js,module.js,loading.js,widget-body.js,widget-footer.js,widget-header.js,widget.js}> /tmp/ext/page/all.js
find /tmp/ext/page/{js,css} -iname '*.js' -type f -print | xargs /bin/rm -f
rm /tmp/ext/.idea -rf
find /tmp/ext -iname '*.js' -type f -print -exec bash -c '/usr/local/bin/uglifyjs --compress "drop_console" --mangle "sort,toplevel,eval" --screw-ie8 -- {} > {}.new; mv {}.new {}' \;
