#!/bin/sh

cd /opt/sas/viya/home/SASFoundation

nohup ./sas -sysin /home/sastest/sbxviya/sasuser.viya/srclib/rdcgrd/0010CRM3plusKeys1_PartCartesianJoin.sas -print /home/sastest/sbxviya/sasuser.viya/output/0010CRM3plusKeys1_PartCartesianJoin2.lst -log /home/sastest/sbxviya/sasuser.viya/log/0010CRM3plusKeys1_PartCartesianJoin2.log & 