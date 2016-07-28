#!/bin/sh

cd /opt/sas/sashome/SASFoundation/9.4/ 

nohup ./sas -sysin /home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0020SKP1plusKeysWithBlue.sas -print /home/sastest/sbxviya/sasuser.viya/output/0020SKP1plusKeysWithBlue.lst -log /home/sastest/sbxviya/sasuser.viya/log/0020SKP1plusKeysWithBlue.log & 
