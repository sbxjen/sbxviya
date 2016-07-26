#!/bin/sh

cd /opt/sas/sashome/SASFoundation/9.4/ 

nohup ./sas -sysin /home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0020BlueByk_tstmat.sas -print /home/sastest/sbxviya/sasuser.viya/output/0020BlueByk_tstmat.lst -log /home/sastest/sbxviya/sasuser.viya/log/0020BlueByk_tstmat.log & 
