
# Send header to CSV file
# Some parts of the header are not necessary here, they are legacy from existing code
echo "\"File\",\"Percentage\",\"System\",\"Context\",\"Strategy\",\"Score\",\"Serial\",\"Informant\",\"Time\",\"Inf\"" >results.csv
# Loop over files and informants in file results and append to CSV file
cat results  | xargs -n 2 ./filter_results.py  >>results.csv

# convert to blank-separated file for peruse by awk
cat results.csv | sed 's/","/ /g' >results.bsv

printf "1. Results with no hint\n"
printf "=======================\n"


printf "Strategy  percentage  avg.   stdev   samples\n"
printf "[both]    [both]     "; cat results.bsv | grep NONE |awk '{r=$6; s+=r; s2+=r*r} END{printf "%6.3f %6.3f %5d\n", s/NR, ((s2-s*s/NR)/NR)^2, NR}'

printf "\n"


printf "2. Machine translation results\n"
printf "==============================\n"
printf "System  percentage context  avg.  stdev  samples\n"

# both percentages

printf "[all]   [both]     [both]  "; cat results.bsv | grep -v NONE |awk '{r=$6; s+=r; s2+=r*r} END{printf "%6.3f %6.3f %5d\n", s/NR, ((s2-s*s/NR)/NR)^2, NR}'
printf "Yandex   [both]     [both]  "; cat results.bsv | grep yandex |awk '{r=$6; s+=r; s2+=r*r} END{printf "%6.3f %6.3f %5d\n", s/NR, ((s2-s*s/NR)/NR)^2, NR}'
printf "Google  [both]     [both]  "; cat results.bsv | grep google |awk '{r=$6; s+=r; s2+=r*r} END{printf "%6.3f %6.3f %5d\n", s/NR, ((s2-s*s/NR)/NR)^2, NR}'
printf "Apertium    [both]     [both]  "; cat results.bsv | grep apertium |awk '{r=$6; s+=r; s2+=r*r} END{printf "%6.3f %6.3f %5d\n", s/NR, ((s2-s*s/NR)/NR)^2, NR}'

printf "Statistical significance tests:\n\n"

printf "Do MT systems help?\n\n"

printf "Testing ([NONE [both] [both]) vs. (Yandex [both]  [both]) \n"
cat results.bsv | grep NONE |awk '{print $6}' >/tmp/a
cat results.bsv | grep google |awk '{print $6}' >/tmp/b
python sigtest.py

printf "Testing ([NONE [both] [both]) vs. (Google [both]  [both]) \n"
cat results.bsv | grep NONE |awk '{print $6}' >/tmp/a
cat results.bsv | grep google |awk '{print $6}' >/tmp/b
python sigtest.py

printf "Testing ([NONE [both] [both]) vs. (Apertium [both]  [both]) \n"
cat results.bsv | grep NONE |awk '{print $6}' >/tmp/a
cat results.bsv | grep apertium |awk '{print $6}' >/tmp/b
python sigtest.py

printf "\n\n"

printf "Are MT systems any different from each other?\n\n"


printf "Testing ([Yandex [both] [both]) vs. (Google [both]  [both]) \n"
cat results.bsv | grep yandex |awk '{print $6}' >/tmp/a
cat results.bsv | grep google |awk '{print $6}' >/tmp/b
python sigtest.py

printf "Testing ([Yandex [both] [both]) vs. (Apertium [both]  [both]) \n"
cat results.bsv | grep yandex |awk '{print $6}' >/tmp/a
cat results.bsv | grep apertium |awk '{print $6}' >/tmp/b
python sigtest.py

printf "Testing ([Google [both] [both]) vs. (Apertium [both]  [both]) \n"
cat results.bsv | grep google |awk '{print $6}' >/tmp/a
cat results.bsv | grep apertium |awk '{print $6}' >/tmp/b
python sigtest.py



