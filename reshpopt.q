\d .ml

k:key args:first each .Q.opt .z.x;
if[not`fin  in k;2"No input file arg"   ;exit 1];
if[not`dtyp in k;2"No datatypes arg"    ;exit 1];
if[not`targ in k;2"No target column arg";exit 1];
if[not`ptyp in k;2"No problem type arg" ;exit 1];
if[any w:0=/:count each args;2"No argument given for ",$[1=count c;raze;", "sv]c:string where w;exit 1];

\l runhpopt.q

.Q.gc[];

st:.z.t;
-1"\nRunning comparison\n";
r:hpopt_mltmodel[hsym`$args`fin;args`dtyp;`$args`targ;args`ptyp];

-1"Saving results";
out:{x,/:y}'[("outputs/",/:("files/";"img/"));(string[key r],\:"_",ssr[;":";"."]"_"sv string(.z.d;.z.t)),\:/:(".txt";".png")];
out:$[w:.z.o like"w*";ssr[;"/";"\\"]@'';]out;
if[not w;{"touch ",x}each out 0];
h:{hopen hsym`$x}each out 0;
{[r;h]h each,\:[;"\n"].ml.i.hptab2str'[sk;value fr;1+max count each sk:string key fr:flip r]}'[r;h];
hclose each h;

-1"\nPlotting results";
plts:i.plt_hpopt_res'[r;out 1];
tm:.z.t-st;

-1"Overall time taken: ",string[tm],". Comparison complete, see outputs/";