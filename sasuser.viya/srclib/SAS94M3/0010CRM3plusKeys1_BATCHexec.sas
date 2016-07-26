#!/bin/sh

cd /opt/sas/sashome/SASFoundation/9.4/ 

nohup ./sas -sysin /home/sastest/sbxviya/sasuser.viya/srclib/SAS94M3/0015CRM3plusKeys6_SortMergeJoin_ext.sas -print /home/sastest/sbxviya/sasuser.viya/output/0015CRM3plusKeys6_SortMergeJoin_ext.lst -log /home/sastest/sbxviya/sasuser.viya/log/0015CRM3plusKeys6_SortMergeJoin_ext.log & 
