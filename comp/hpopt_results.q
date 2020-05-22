/
The current implementation will only run with set parameters.
To run the function `.ml.save_hpopt_res` use the following:

```
$ q hpopt_results.q
q)fin  :"data.csv"  / works with any csv containing a kdb table
q)fout :"results"   / works with any name
q)dtype:"FFFFFIB"
q)targ :`x6
q)param:`seed`k`n`test`trials!(42;5;1;.2;1024)  / current working parameters
q).ml.save_hpopt_res[fin;fout;dtype;targ;param];
Running comparison
Plotting results
Saving results
Comparison complete, see outputs/
```

Results can be reloaded using `.ml.load_hpopt_res`:

```
q).ml.load_hpopt_res["outputs/files/";"results.txt"]
alpha        average fold_score                     l1_ratio  method   random_state time score
----------------------------------------------------------------------------------------------
0.02438354   0       1     0.99375 0.58125 1 1      0         grid     42                1    
0.0003729849 0       1     0.99375 0.8125  1 1      0.4863586 random   42                1    
0.0001647392 0       1     0.975   0.95    1 1      0.3925781 sobol    42                1    
0.00145952   0       0.975 1       0.975   1 0.9125 1         bayesian 42                0.995
```
\


\l hpopt_compare.q

\d .ml

// comparison function which saves results
/* fin   = file path to data in string format, e.g. "data.csv" - saved in the working directory
/* fout = output file as a string, e.g. "results" - saved in "outputs/files"
/* dtype = column datatypes to be read in in string format, e.g. "SSFIJ"
/* targ  = target column as a symbol, e.g. `x4
/* param = dictionary of parameters for `seed`k`n`test`trials
/. r     > function returns nothing, outputs saved in "outputs/"
save_hpopt_res:{[fin;fout;dtype;targ;param]
  // initialise with gc
  .Q.gc[];
  // start time
  st:.z.t;
  // run function
  -1"Running comparison";
  r:hpoptcomp[fin;dtype;targ;param];
  // plot results
  -1"Plotting results";
  plt:i.plt_hpopt_res[r;1b];
  // get the run timing
  tm:.z.t-st;
  // create output file paths
  -1"Saving results";
  out:("outputs/",/:("files";"img"),\:"/"),'fout,/:(".txt";".png");
  out:$[w:.z.o like"w*";ssr[;"/";"\\"];]each out; 
  // open handle to results file and write to it
  if[not w;"touch ",out 0];
  h:hopen hsym`$out 0;
  h each,\:[;"\n"]i.hptab2str'[sk;value fr;1+max count each sk:string key fr:flip r];
  hclose h;
  // plot and save results
  plt[`:savefig]out 1;
  -1"Comparison complete, see outputs/"}

// load in previous results table - note hyperparameters are loaded as symbols
/* fp = file path, e.g. "outputs/files/"
/* fn = file name, e.g. "results.txt"
/. r  > returns results table
load_hpopt_res:{[fp;fn]
  // read data into dictionary
  get_data:{fnc:{key(!).("S=,")0:x};$[1<count first x;fnc each;fnc]x};
  d:get_data each@[d;;";"vs]c:where";"in/:d:(!).("S*";"|")0:hsym`$fp,fn;
  // convert standard columns to set types
  flip{@[x;y;$[z;]string@]}/[d;`fold_score`random_state`time`score;"FIZF"]}

// string results table
/* k  = keys
/* v  = values
/* mx = maximum characters in key name
i.hptab2str:{[k;v;mx](mx#k,mx#" "),"| ",$[1=count first v;","sv;(" ; "sv","sv/:)]string v}