\l runhpopt.q

\d .ml

args:.Q.opt .z.x;
if[not count fin :args`fin ;2"No input file arg"   ;exit 1];
if[not count fout:args`fout;2"No output file arg"  ;exit 1];
if[not count dtyp:args`dtyp;2"No datatypes arg"    ;exit 1];
if[not count targ:args`targ;2"No target column arg";exit 1];

.Q.gc[];

st:.z.t;
-1"Running comparison";
r:hpopt_mltmodel[hsym`$fin;dtyp;`$targ];
-1"Plotting results";
plt:i.plt_hpopt_res[r;1b];
tm:.z.t-st;

-1"Saving results";
out:("outputs/",/:("files";"img"),\:"/"),'fout,/:(".txt";".png");
out:$[w:.z.o like"w*";ssr[;"/";"\\"];]each out; 
if[not w;"touch ",out 0];
h:hopen hsym`$out 0;
h each,\:[;"\n"]i.hptab2str'[sk;value fr;1+max count each sk:string key fr:flip r];
hclose h;

-1"Saving plots";
plt[`:savefig]out 1;

-1"Comparison complete, see outputs/";