#!/usr/bin/python

# Copyright: (C) 2017 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Damiano Malafronte <https://github.com/damianomal>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

import random
import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument("-n", "--number", type=int, help="number of users to extract (default: 3)", default=3)
parser.add_argument("-f", "--file", type=str, help="Gradebook.md file to be processed (default: ../final-gradebook.md)", default='../final-gradebook.md')
args = parser.parse_args()

# by default, extracts 3 users from the 'final-gradebook.md' file
USER_LIMIT = args.number
fname = args.file

# tries to open the chosen file, the default file name
# is the one selected in the parser
try:
	with open(fname) as f:
		all_lines = f.readlines()
except getattr(__builtins__,'FileNotFoundError', IOError):
	print "#### the file %s has not been found! ####" % fname
	sys.exit()

# trims every line in the input file
all_lines = [x.strip().replace(" ", "") for x in all_lines] 

# list which will contain the users rankings 
users = []

# adds each user's score to the list just created
for line in all_lines: 
	if "http" in line:
		array = line.split("**")
		users.append((array[1],int(array[3])))

# this line can be commented if the list of 
# users is already sorted
users.sort(key=lambda l: l[1], reverse=True)

# DEBUG: prints all the users contained in the file
# for pair in users: 
# 	print "User %s scored %d" % (pair[0], pair[1])

# resulting list from the process
chosen = []

# iteratively selects a subset of the users, starting 
# from those in the first positions of the 'users' list
while len(users) > 0:

	# select the subset of users with the current maximum score
	subset = [l for l in users if l[1] == users[0][1]]

	# select either the whole subset of users or only a part of it
	if(len(subset) + len(chosen) > USER_LIMIT):
		chosen += [subset[i] for i in random.sample(xrange(len(subset)), USER_LIMIT-len(chosen))]
		break
	else:
		chosen += subset
		users = users[len(subset):]

# opens a file for output and writes there the results of the process
with open('selected-team-leaders.md', 'w') as out_file:
	for pair in chosen: 
		print "--- Chosen user %s with score %d" % (pair[0], pair[1])
		out_file.write('--- Chosen user ' + pair[0] + ' with score ' + str(pair[1]) + '\n')
	
