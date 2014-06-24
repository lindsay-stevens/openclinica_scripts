/*  code adapted from http://stackoverflow.com/a/8569808 */
/*  filename tip https://groups.google.com/d/msg/comp.soft-sys.sas/CKCoH-j4lXs/vikDCisbtEsJ */
/*  Configuration
    no quotes are required for the directory names, even if there are spaces,
    however a trailing slash must be included.
    csvdir = folder where the csv files are located.
    outdir = folder where the sas or files will be created, must exist already
    outmode = dta or sas. 
      dta mode
        creates dta files, which are compatible with both SAS and Stata
        the file names for this mode are the same as the input csv files
      sas mode
        because sas library member names must be 8 characters or less, this
        creates sas7bdat files named with first 6 characters of file name
        and a number corresponding to alphabetical order of the file e.g. 
        ig_a1102_visitcen.csv becomes ig_a1_1.sas7bdat
        ig_a1102_visitlab.csv becomes ig_a1_2.sas7bdat
*/
%let csvdir=C:\Users\Lstevens\Desktop\mystudy\;
%let outdir=C:\Users\Lstevens\Desktop\mystudy\sas\;
%let outmode=sas;

/* Data set with one observation for each csv file name */
filename fnames pipe "dir /b ""&csvdir""*.csv";
data fnames;
    infile fnames pad missover;
    input @1 filename $255.;
    n=_n_;
run;

/* Store the number of files in a macro variable "num" */
proc sql noprint; select count(filename) into :num from fnames; quit;

/* Macro to iterate over the filenames, import then export */
%macro doit(outmode);
    %do i=1 %to &num;

        /* read in list of file names */
        proc sql noprint;
            select filename into :filename from fnames where n=&i;
        quit;

        /* create shorter name for the library name of the file dataset  */
        %let outfile=%substr(&filename,1,5)_%trim(&i);
        %let csvin="&csvdir.%trim(&filename)";

        /* sas mode sets the import library as the outdir directory*/
        %if &outmode=sas %then
            %do;
                libname csvlib "&outdir";
                proc import 
                    datafile=&csvin out=csvlib.&outfile replace;
                    getnames=yes; 
                    datarow=2; 
                    guessingrows=32767;
                run;
            %end;

        /* dta mode puts the data in the work library, then exports to outdir */
        %else %if &outmode=dta %then
            %do;
                proc import 
                    datafile=&csvin out=&outfile replace;
                    getnames=yes; 
                    datarow=2; 
                    guessingrows=32767;
                run;
                proc export
                    data=&outfile outfile="&outdir.%substr(&filename,1,
                        %length(&filename)-4).dta";
                run;
            %end;
    %end;
%mend;

/* run the above macro */
%doit(&outmode);