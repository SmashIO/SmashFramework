date
echo "Removing Previous Docs"
rm -rf docs
/projects/libraries/docco/bin/docco \
    `find /projects/libraries/pbe2/src/* | grep \\.as | grep -v greensock` `find /projects/libraries/pbe2/examples/* | grep \\.as | grep -v greensock`