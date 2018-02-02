#!/bin/bash

function generate_rambox() {
	local path=$1
	local website=$2
	echo "Generating CSS for Rambox for website: ${website} (filename: ${path})..."

	# Calculate lines count.
	lines=$(cat ${path} | wc -l)
	echo -e "\tOriginal Stylish file lines count: ${lines}"
	echo -e "\tWill use $[ ${lines} - 2 ] lines from file"

	# Get rid of first two lines.
	cat ${path} | tail -n $[ ${lines} - 2 ] > ./${website}/rambox.cssjs1
	
	# Get rid of last line.
	cat ./${website}/rambox.cssjs1 | head -n $[ ${lines} - 2 - 1 ] > ./${website}/rambox.cssjs2
	rm ./${website}/rambox.cssjs1

	# Remove comments.
	cat ./${website}/rambox.cssjs2 | grep -v "*/" > ./${website}/rambox.cssjs3
	rm ./${website}/rambox.cssjs2

	# Replace all "\n"s.
	tr '\n' ' ' < ./${website}/rambox.cssjs3 > ./${website}/rambox.cssjs4
	rm ./${website}/rambox.cssjs3

	# Remove excessive spaces.
	cat ./${website}/rambox.cssjs4 | sed -e "s/\ \ /\ /g" > ./${website}/rambox.cssjs5
	rm ./${website}/rambox.cssjs4
	cat ./${website}/rambox.cssjs5 | sed -e "s/\ \ /\ /g" > ./${website}/rambox.cssjs6
	rm ./${website}/rambox.cssjs5

	# Add Rambox-specific data to final file.
	echo -e "function cssEngine(rule) {" > ./${website}/rambox.cssjs
	echo -e "    var css = document.createElement('style');" >> ./${website}/rambox.cssjs
	echo -e "    css.type = 'text/css';" >> ./${website}/rambox.cssjs
	echo -e "    css.appendChild(document.createTextNode(rule));" >> ./${website}/rambox.cssjs
	echo -e "    document.getElementsByTagName('head')[0].appendChild(css);" >> ./${website}/rambox.cssjs
	echo -e "}" >> ./${website}/rambox.cssjs
	echo -e "" >> ./${website}/rambox.cssjs
	echo -n -e "cssEngine('" >> ./${website}/rambox.cssjs
	cat ./${website}/rambox.cssjs6 | tr '\n' ' ' >> ./${website}/rambox.cssjs
	echo -e "');" >> ./${website}/rambox.cssjs
	rm ./${website}/rambox.cssjs6
}

for file in $(find . -type f -name "stylish.css"); do
	website=$(echo $file | cut -d "/" -f 2)
	generate_rambox $file $website
done
