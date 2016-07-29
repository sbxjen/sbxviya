#!/bin/sh

cd /opt/sas/sashome/SASFoundation/9.4/ 

nohup ./sas -sysin /home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/$1.sas -print /home/sastest/sbxviya/sasuser.viya/output/$1.lst -log /home/sastest/sbxviya/sasuser.viya/log/$1.log & 
