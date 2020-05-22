\l ../random/xval_updated.q

\d .ml

// run all hyperparameter optimization methods
/* fin   = file path to data in string format, e.g. "data.csv", stored in the working directory
/* dtype = column datatypes to be read in in string format, e.g. "SSFIJ"
/* targ  = target column as a symbol, e.g. `x4
/* param = dictionary of parameters for `seed`k`n`test`trials
/. r     > returns a table of results
hpoptcomp:{[fin;dtype;targ;param]
  
  // set random seed
  system"S ",string param`seed;
  
  // read in data, separate target and convert to matrix
  d:(dtype;",",())0:hsym`$fin;
  data:flip d c:cols[d]except targ; 
  targ:d targ;

  // GRID SEARCH

  // gs scoring func
  scf:xv.fitscore{.p.import[`sklearn.linear_model]`:SGDClassifier};
  // grid hp
  gs_01_gen:{((0.,(1_til x-1)*10%x-1),10.)%10};
  gshp:`random_state`average`l1_ratio`alpha!(param`seed;01b;gs_01_gen 16;xexp[10](gs_01_gen[32]*7)-5);
  // run grid search
  st:.z.t;
  res_gs:gs.kfsplit[;;data;targ;scf;gshp;]. param`k`n`test;
  res_gs:i.run_comp[res_gs;`grid;.z.t-st];

  // RANDOM SEARCH

  // pseudo- and sobol-random hp
  rshp:`average`l1_ratio`alpha!(`boolean;(`uniform;0;1;"f");(`loguniform;-5;2;"f"));
  prdm:`typ`random_state`n`p!(`random;param`seed;param`trials;rshp);
  psbl:`typ`random_state`n`p!(`sobol ;param`seed;param`trials;rshp);
  // run pseudo-random search
  st:.z.t;
  res_rdm:rs.kfsplit[;;data;targ;scf;prdm;]. param`k`n`test;
  res_rdm:i.run_comp[res_rdm;`random;.z.t-st];
  // run sobol-random search
  st:.z.t;
  res_sbl:rs.kfsplit[;;data;targ;scf;psbl;]. param`k`n`test;
  res_sbl:i.run_comp[res_sbl;`sobol;.z.t-st];

  // BAYESIAN SEARCH

  // create split data for bayesian search
  hout:traintestsplit[data;targ;param`test];
  splt:raze(.ml.xv.i.idxR . .ml.xv.i`splitidx`groupidx)[param`k;param`n]. hout`xtrain`ytrain;  / equivalent to kfsplit
  // import python functions
  re :.p.import[`skopt.space]`:Real;
  cat:.p.import[`skopt.space]`:Categorical;
  SGD:.p.import[`sklearn.linear_model]`:SGDClassifier;
  // bayesian hp
  bshp:`average`l1_ratio`alpha!
    (cat[01b]`;re[0;1;`prior pykw"uniform"]`;re[.00001;100;`prior pykw"log-uniform"]`);
  // run bayesian
  st:.z.t;
  res_bs:bs.bsCV[SGD;splt;hout;bshp;param`seed];
  res_bs:i.run_comp[res_bs;`bayesian;.z.t-st];

  // return results in table
  r:(res_gs;res_rdm;res_sbl;res_bs);
  update score:r[;1]from{k!x k:asc key x}each r[;0]}

i.run_comp:{[r;typ;tm]
  -2#@[r;1;(`method`time`fold_score!(typ;tm;$[typ in`random`sobol`grid;r[0]value r 1;r 0])),]}

i.plt_hpopt_res:{[r;saveplt]
  scores:select i,method,fold_score from r;
  toplt:flip raze{x[`x],/:x`fold_score}each scores;
  plt:.p.import`matplotlib.pyplot;
  plt[`:scatter]. toplt;
  plt[`:xticks]. scores`x`method;
  plt[`:xlabel]"Method";
  plt[`:ylabel]"Score";
  plt[`:title]"K-fold score spread for hyperparameter optimization methods";
  $[saveplt;plt;plt[`:show][];]}