#!/bin/sh

cd /opt/sas/sashome/SASFoundation/9.4/ 

nohup ./sas -sysin /home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0010CRM3plusKeys.sas -print /home/sastest/sbxviya/sasuser.viya/output/0010CRM3plusKeys.lst -log /home/sastest/sbxviya/sasuser.viya/log/0010CRM3plusKeys.log & 