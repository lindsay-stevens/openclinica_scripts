/*  code adapted from http://stackoverflow.com/a/8569808 */
/*  filename tip https://groups.google.com/d/msg/comp.soft-sys.sas/CKCoH-j4lXs/vikDCisbtEsJ */
/*  Configuration
    no quotes are required for the directory names, even if there are spaces,
    however a trailing slash must be included.
    xlsxdir = folder where the xlsx files are located.
    outdir = folder where the sas or files will be created, must exist already
    outmode = dta or sas. 
      dta mode
        creates dta files, which are compatible with both SAS and Stata
        output file names are the same as the input xlsx files
      sas mode
        creates sas7bdat files, which are compatible with SAS only
        output file names are the first 32 characters of the input xlsx files
*/
%let xlsxdir=C:\Users\Lstevens\Desktop\mystudy\xlsx\;
%let outdir=C:\Users\Lstevens\Desktop\mystudy\sas\;
%let outmode=sas;

/* Data set with one observation for each xlsx file name */
filename fnames pipe "dir /b ""&xlsxdir""*.xlsx";
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

        /* memname = shorter name for the library name of the file dataset  */
        /* outname = file name without xlsx extension for naming the outfiles*/
        %let memname=%substr(&filename,1,5)_%trim(&i);
        %let outname=%substr(&filename,1,%length(&filename)-5);
        %let xlsxin="&xlsxdir.%trim(&filename)";

        /* sas mode sets the import library as the outdir directory*/
        %if &outmode=sas %then
            %do;
                libname xlsxlib "&outdir";
                proc import 
                    datafile=&xlsxin out=xlsxlib.&memname dbms=excel replace;
                        getnames=yes;
                        mixed=no;
                        scantext=yes;
                        usedate=yes;
                        textsize=4000;
                run;
                /* rename dataset with first 32 chars of original file name */
                data _null_;
                    %let maxname=%substr(&outname,1,32);
                    rc=rename("xlsxlib.&memname","&maxname");
                run;
            %end;

        /* dta mode puts the data in the work library, then exports to outdir */
        %else %if &outmode=dta %then
            %do;
                proc import 
                    datafile=&xlsxin out=&memname dbms=excel replace;
                        getnames=yes;
                        mixed=no;
                        scantext=yes;
                        usedate=yes;
                        textsize=4000;
                run;
                proc export
                    data=&memname dbms=dta outfile="&outdir.&outname";
                run;
            %end;
    %end;
%mend;

/* run the above macro */
%doit(&outmode);