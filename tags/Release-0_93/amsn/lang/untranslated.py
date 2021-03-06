#! /usr/bin/env python
# Author: Hatredman
# Use: untranslated.py langXX
# lists all missing translations keys in language
# Based on the missing.py script 
# by Gustavo Caneiro and Alvaro J. Iradier

import string
import fileinput

msg_list = {}


for line in fileinput.input("langen"):
    i = string.find(line, ' ')
    if i < 0: continue
    key = line[:i]
    val = line[i+1:]
    msg_list[key] = val



for line in fileinput.input():
    tokens = string.split(line)
    key = tokens[0]
    try:
	del msg_list[key]
    except KeyError: pass
    # print string.rstrip(line)

print
print
print "Keys needing translation:"
cont=0
for key, val in msg_list.items():
    cont=cont+1
    print string.rstrip(key)
    
print
print "---------------------------------------------------"
print "Missing (untranslated) keys:",cont
print
