date
echo "Removing Previous Docs"
rm -rf docs
/projects/libraries/docco/bin/docco \
    `find /projects/libraries/SmashFramework/src/ -name "*.as"` `find /projects/libraries/SmashFramework/examples/ -name "*.as" | grep -v greensock`