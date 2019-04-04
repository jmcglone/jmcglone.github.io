rm -rf cycles.csv
grep "0000000000400e0b" dump.txt | grep "cycles" | sort > cycle_lines.txt
sed 's/.*PRED \(.*\) cycles.*/\1/' cycle_lines.txt > cycles.txt
uniq cycles.txt uniq.txt
cat uniq.txt | while read line ; do echo -n $line"," >> cycles.csv && grep $line cycles.txt -w -c >> cycles.csv ; done
