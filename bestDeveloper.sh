#!/bin/bash

echo "==========================================================================="

echo "Program written by Michelle L. Gbolumah"
echo "ABOUT THIS PROGRAM: This program takes a GitHub project and finds the 
'best developer' in that project. In this example, 'best developer' is defined as 
the developer who contributes the most commits to the project. Currently, this 
program can only intake one GitHub project at a time."

echo "==========================================================================="

echo "======= Step 1: Download the GitHub project. ======="
while read project
	do
		# Downloads the GitHub project.
		git clone $project
		# Takes the GitHub URL and replaces the '/' with spaces.
		projectpathPart1=(` echo $project | tr '/' ' ' ` )
		# Defines a variable as the last part of the GitHub URL. Will be used later. 
		projectpathPart2="${projectpathPart1[3]}"
		# The GitHub project's path.
		projectpathPart3="$(pwd)/$projectpathPart2"
		echo "Downloaded the '$project' project."
	# The links.txt file must contain only one GitHub URL in the following format:
	# https://github.com/JakeWharton/ActionBarSherlock.
	done < links.txt

echo "======= Step 2: Get the GitHub project's logs. ======="
echo "--> The directory I am currently in is: $(pwd)."
# Navigates to the GitHub project's directory.
cd $projectpathPart3
echo "--> Now I am in the GitHub project's directory so I can copy its log files:
$(pwd)."
# Takes the GitHub project's logs and copies its logs. Will be used later.
# The name of the log file you're creating is the name of the GitHub project 
# (that we parsed from the GitHub URL earlier) + _log.txt.
git log > ../${projectpathPart2}_log.txt
# Navigate one level up from the GitHub project's directory.
cd ../
# Display all of the contents of the pwd to ensure the newly created log file is
# in there.
echo "--> Now I am one level up from the GitHub project's directory so I can ensure
the project's log files were copied."
echo *

# Delete Developers.csv if it already exists.
rm -rf Developers.csv

echo "======= Step 3: Read the GitHub project's log file and write the 
developer names, emails, and commit IDs to Developers.csv. ======="
while read line
	do
		# Read and write developer names and emails.
		if [[ $line = "Author: "* ]]; then
			developerName=(` echo $line | tr ' ' ',' ` )
			developerName2=(` echo $developerName | tr -d '<' ` )
			developerName3=(` echo $developerName2 | tr -d '>' ` )
			developerName4=(` echo $developerName3 | sed 's/^........//' `)
		fi

		# Associate commits with developers.
		if [[ $line = "commit "* ]]; then
			commit=(` echo $line | sed 's/^.......//' `)
			commit2="$developerName4,$commit"
			echo $commit2 >> Developers.csv
		fi
	done < "${projectpathPart2}_log.txt"

# Delete Score.csv if it already exists.
rm -rf Score.csv

echo "======= Step 4: Count the number of occurrences of each email address 
in the Developers.csv file and sort it from greatest to least. Because each commit 
is associated with an email address, we can say that each occurrence of an email 
address counts as a commit. Thus, we can get the number of commits for a developer. ======="
grep -o '[[:alnum:]+\.\_\-]*@[[:alnum:]+\.\_\-]*' Developers.csv | sort | uniq -c -i | sort -nr >> Score.csv

# Delete DeveloperScores.csv if it already exists.
rm -rf DeveloperScores.csv

echo "======= Step 5: From that sorted list, assign number of commits to a 
variable and assign developer emails to another variable. The variable containing 
the number of commits will be used to calculate the score for each developer email.
Organize all of this information in a CSV. ======="
while read line
	do
		numberofCommits=$(echo $line | cut -d' ' -f 1)
		developerEmail=$(echo $line | cut -d' ' -f 2)
		numberofProjects=1
		# State the best developer: 
		#Score = (number of Projects * 0.3) + (Number of commits * 0.7).
		score=`echo "0.3 + $numberofCommits * 0.7" | bc`
		echo "$developerEmail,$numberofProjects,$numberofCommits,$score" >> DeveloperScores.csv
	done < Score.csv

echo "======= Step 6: From that CSV, find and report the best developer. ======="
while read line
	do
		developerEmail2=$(echo $line | cut -d',' -f 1)
		score2=$(echo $line | cut -d',' -f 4)
		echo "$developerEmail2 is the best developer with a score of $score2!"
		break
	done < DeveloperScores.csv
