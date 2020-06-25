\d .ml

// run hyperparameter optimization comparison for multiple ML models
/* fin  = file path to input data, e.g. `:data.csv
/* dtyp = datatypes in CSV, e.g. "FFFSB"
/* targ = target column as a symbol, e.g. `x4
/. r    > returns a results table with best hyperparameters for each method
hpopt_mltmodel:{[fin;dtyp;targ;ptyp]
  system"l userhp_",ptyp,".q";
  // read in data, separate target and convert to matrix
  data:flip d c:cols[d:(dtyp;",",())0:fin]except targ; 
  targ:d targ;
  // run comparison for each model
  hpopt_sglmodel[data;targ;;;;;]'[scf;mdl_import[];gshp;rshp;bshp]}

// run hyperparameter optimization comparison of grid, random, sobol-random and bayesian search
/* data  = data from csv
/* targ  = target column as list
/* score = scoring function required for grid and random search methods
/* mdl   = projection of python model
/* g     = grid search hyperparameters
/* r     = random search hyperparameters
/* s     = sobol-random search hyperparameters
/* b     = bayesian search hyperparameters
/.       > returns a results table with best hyperparameters for each method
hpopt_sglmodel:{[data;targ;score;mdl;g;r;b]
  // set random seed
  system"S ",string prms`seed;
  // check number of trials works for sobol
  sbl_check:{[trials]v="i"$v:xlog[2;trials]};
  $[sbl_check count(cross/)g;;'"number of trials must equal 2^x"];
  // run grid search
  -1"Running grid search";
  st:.z.t;
  res_gs:gs.kfsplit[;;data;targ;score;g;]. prms`k`n`test;
  res_gs:i.run_comp[res_gs;`grid;.z.t-st];
  // run pseudo-random search
  rdmhp:`typ`random_state`n`p!(`random;prms`seed;prms`trials;r);
  sblhp:`typ`random_state`n`p!(`sobol ;prms`seed;prms`trials;r);
  -1"Running random search";
  st:.z.t;
  res_rdm:rs.kfsplit[;;data;targ;score;rdmhp;]. prms`k`n`test;
  res_rdm:i.run_comp[res_rdm;`random;.z.t-st];
  // run sobol-random search
  -1"Running Sobol search";
  st:.z.t;
  res_sbl:rs.kfsplit[;;data;targ;score;sblhp;]. prms`k`n`test;
  res_sbl:i.run_comp[res_sbl;`sobol;.z.t-st];
  // create split data for bayesian search
  hout:traintestsplit[data;targ;prms`test];
  // the below is equivalent to kfsplit
  splt:raze(.ml.xv.i.idxR . .ml.xv.i`splitidx`groupidx)[prms`k;prms`n]. hout`xtrain`ytrain;
  // run bayesian
  -1"Running Bayesian search";
  st:.z.t;
  res_bs:bs.bsCV[mdl[];splt;hout;b;prms`seed];
  res_bs:i.run_comp[res_bs;`bayesian;.z.t-st];
  // return results in table
  res:(res_gs;res_rdm;res_sbl;res_bs);
  -1"Returing results\n";
  update score:res[;1]from{k!x k:asc key x}each res[;0]}

// load in previous results table - note hyperparameters are loaded as symbols
/* fp = file path, e.g. "outputs/files/"
/* fn = file name, e.g. "results.txt"
/. r  > returns results table
load_hpopt_res:{[fp;fn]
  // read data into dictionary
  get_data:{fnc:{key(!).("S=,")0:x};$[1<count first x;fnc each;fnc]x};
  d:get_data each@[d;;";"vs]c:where";"in/:d:(!).("S*";"|")0:hsym`$fp,fn;
  // convert standard columns to set types
  flip{@[x;y;$[z;]string@]}/[d;`fold_score`random_state`time`score;"FITF"]}

i.run_comp:{[r;typ;tm]
  -2#@[r;1;(`method`time`fold_score!(typ;tm;$[typ in`random`sobol`grid;r[0]value r 1;r 0])),]}

i.plt_hpopt_res:{[r;fpath]
  scores:select i,method,fold_score from r;
  toplt:flip raze{x[`x],/:x`fold_score}each scores;
  plt:.p.import`matplotlib.pyplot;
  plt[`:scatter]. toplt;
  plt[`:xticks]. scores`x`method;
  plt[`:xlabel]"Method";
  plt[`:ylabel]"Score";
  plt[`:title]"K-fold score spread for hyperparameter optimization methods";
  -1"Saving plots";
  plt[`:savefig]fpath;
  plt[`:clf][];}

i.hptab2str:{[k;v;mx](mx#k,mx#" "),"| ",$[1=count first v;","sv;(" ; "sv","sv/:)]string v}