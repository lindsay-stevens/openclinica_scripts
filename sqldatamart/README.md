#Outline
This is a mini-project to improve the openclinica community datamart. The aim is to enable live reporting.

The [existing process](http://en.wikibooks.org/wiki/OpenClinica_User_Manual/CommunityDataMart) which using Access works fine but currently in our setup it takes about 15 or 20 minutes to process 300k rows of clinicaldata for 7 studies. This is OK for running daily at midnight, but way too long for live reporting. 

Another issue is that the current process drops the reporting database each time it is run, so if it was re-run more than daily it would result in unacceptable downtime.

It is important that the final product is as close to a drop-in replacement for the existing process as possible (that is, it produces the same stuff) since there has been significant work put in to writing reports using data from the current process.

##Steps to success
TODO:
1. Take Access out of the equation by doing everything in Postgres. This also has the advantage of (theoretically) allowing *nix installations use it.
2. Rework the warehousing script so that it performs well as views instead of the current system of writing out to table(s).
3. Set up replication so that the views are processed on the datamart server and not the webapp server (also so that end users aren't connecting to the webapp server).

###1. Take Access out of the equation
Created a new sql file called oc_transform_datasets. Intended functions:
TODO:
1. Create a schema for each study
2. Create a database user for each study
3. Create per-study views for common tables (subject list, etc)
4. Create separate script for the hack to serialise tables with > 255 columns
DONE:
5. Create views for all item group tables.

###5. Create views for all item group tables
oc_transform_datasets generates and executes CREATE VIEW AS SELECT... statements for views with transform / pivot the data such that each item has it's own column and accompanying label column if it is a coded item. 

The generated views seem to run nearly twice as fast when using the index: "CREATE INDEX idx_item_group_oid_study_name ON dm.clinicaldata USING btree (item_group_oid, study_name);"

The views use max case pivots. I thought they would be horribly slow, but of those I looked at, the longest dataset (70col x 500row) runs in 400ms and the widest dataset (270col x 60rows) runs in 1200ms. The hash aggregate step is about 90% of the execution time, but I'm not sure that can be improved.

I have had a look at the tablefunc module crosstab function but found it requires about as much explicit column naming as using max case pivots.

##2. Rework the warehousing script
It currently takes just under 3 minutes to generate the final 10 tables. A fair chunk of the execution time is probably in the generation of single-use indexes and manual analyzes. 

It would simplify the item group views to continue to use a central set of views to gather the data from the openclinica schema.

##3. Set up replication
Currently, other than knowing that replication is possible and that many smart people in the world have done it, I have no idea how to do it. So we will cross that road when we come to it.