#!/usr/bin/env bash

target_dir="$1"
need_remove_extern_file=true
if [ "$2" == "+extern" ]; then
    need_remove_extern_file=true
fi

DOT=dot # graphviz default layout
#DOT=circo # 
#DOT=twopi
#DOT=fdp
#DOT=neato # sprint model

TMP_PREFIX=/tmp/tmp.$$
TMP_LIST=$TMP_PREFIX.list
TMP_PAIR=$TMP_PREFIX.pair

LEN=`echo $target_dir|gawk '{print length($0)}'`
find $target_dir -name "*.h" -or -name "*.hpp" -or -name "*.c" -or -name "*.cpp" | gawk "{print substr(\$0,$LEN+1)}"|sed 's/^\///;'|sort > $TMP_LIST

cat $TMP_LIST | while read file;
do
cat "$target_dir"/$file | grep '^[ ]*#include'|sed 's/^[ ]*#include[ ]*//'|sed 's/\r//g;s/"//g;s/^<//;s/>//;'|gawk -F"\r" '{print $1}'|gawk '{print $1, "\t", "'"$file"'"}'
done | sort > $TMP_PAIR


function cat_result_pair()
{
    if $need_remove_extern_file ; then
        join $TMP_LIST $TMP_PAIR
    else
        cat $TMP_PAIR
    fi
}

cat_result_pair |gawk '
BEGIN{print "digraph G {"}
{printf("\"%s\" -> \"%s\";\n",$2,$1)}
END{print "}"}
' | $DOT -Tpng

#rm $TMP_LIST $TMP_PAIR

