#! /bin/bash
mkdir -p gen

for file in $(ls *.dot)
do
    echo dot $file
    name="$(echo $file | sed s/\\.dot$//)"
    #dot -Tsvg -ogen/"$name".svg $file
    dot -Tpng -ogen/"$name".png $file
done





