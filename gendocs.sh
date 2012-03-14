date
echo "Removing Previous Docs"
rm -rf docs
/projects/libraries/docco/bin/docco \
    `find /projects/libraries/SmashFramework/src/* | grep \\.as | grep -v greensock` `find /projects/libraries/SmashFramework/examples/* | grep \\.as | grep -v greensock`