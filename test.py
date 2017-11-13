#! /usr/bin/python
from sys import *
from TOSSIM import *
from tinyos.tossim.TossimApp import *

n = NescApp()
t = Tossim(n.variables.variables())
m = t.mac();
r = t.radio();

log = open("log.txt", "w")

t.addChannel("BlinkToRadioC", log)
t.addChannel("Boot", sys.stdout)

f = open("linkgain.out", "r")
for line in f:
  s = line.split()
  if s:
      print " ", s[0], " ", s[1], " ", s[2];
      r.add(int(s[0]), int(s[1]), float(s[2]))


noise = open("meyer-heavy.txt", "r")
lines = noise.readlines()
for line in lines:
  str = line.strip()
  if str:
	val = int(str)
	for i in range(7):	
		t.getNode(i).addNoiseTraceReading(val)		

for i in range(7):
  print "Creating noise model for ",i;
  t.getNode(i).createNoiseModel()
  t.getNode(i).bootAtTime(i * 2351217 + 23542399)

for i in range(7):	
	while (t.getNode(i).isOn()==0):
  		t.runNextEvent();


m = t.getNode(4)
v = m.getVariable("BlinkToRadioC.counter")

while (v.getData() < 10):
  print "Node 4's counter= ", v.getData()
  t.runNextEvent()

print "Counter variable at node 4 reached 10."



