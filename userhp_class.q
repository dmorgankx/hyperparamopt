/
In this script we generalize the process of producing hyperparameter sets for different models.
These sets will then be passed to the hpopt_results.q script to run each model and compare results
 across each method of hyperparameter generation.
\
\l xval_updated.q

\d .ml

prms:`seed`k`n`test`trials!(42;5;1;.2;256);

// starting with classification models
/* lib = library model belongs to, e.g. sklearn, keras, etc.
/* fnc = module the model belongs to
/* mdl = model name
lib:4#`sklearn
fnc:`linear_model,3#`ensemble
mdl:`SGDClassifier`AdaBoostClassifier`GradientBoostingClassifier`RandomForestClassifier
models:([]lib;fnc;mdl)

// function creates a projection for passing into grid search
pyproj:{{[x;y;z].p.import[x]y}[` sv x`lib`fnc;hsym x`mdl]}

// generate scoring functions
scf:xv.fitscore@/:mdl_import:pyproj each models

// grid hp
gs_01_gen:{l:((0.,(1_til x-1)*10%x-1),10.)%10;(l*z+abs y)+y}
gshp:models[`mdl]!
  (`random_state`average`l1_ratio`alpha!(prms`seed;01b;gs_01_gen[8;0;1];xexp[10]gs_01_gen[16;-5;2]);
   `random_state`n_estimators`learning_rate!(prms`seed;"j"$10*1+til 8;xexp[10]gs_01_gen[32;-3;0]);
   `random_state`n_estimators`learning_rate!(prms`seed;"j"$10*1+til 8;xexp[10]gs_01_gen[32;-3;0]);
   `random_state`n_estimators`max_depth`criterion!(prms`seed;"j"$10*1+til 8;"j"$6*1+til 16;`gini`entropy))

// RANDOM SEARCH
// pseudo- and sobol-random hp
rshp:models[`mdl]!
  (`random_state`average`l1_ratio`alpha!((`rand;prms`seed);`boolean;(`uniform;0;1;"f");(`loguniform;-5;2;"f"));
   `random_state`n_estimators`learning_rate!((`rand;prms`seed);(`uniform;1;2;"j");(`loguniform;-3;0;"f"));
   `random_state`n_estimators`learning_rate!((`rand;prms`seed);(`uniform;1;2;"j");(`loguniform;-3;0;"f"));
   `random_state`n_estimators`max_depth`criterion!((`rand;prms`seed);(`uniform;1;2;"j");(`uniform;1;2;"j");(`symbol;`gini`entropy)))

// BAYESIAN SEARCH
// import python functions
re :.p.import[`skopt.space]`:Real;
int:.p.import[`skopt.space]`:Integer;
cat:.p.import[`skopt.space]`:Categorical;

// bayesian hp
bshp:models[`mdl]!
  (`average`l1_ratio`alpha!(cat[01b]`;re[0;1;`prior pykw"uniform"]`;re[1e-005;100f;`prior pykw"log-uniform"]`);
   `n_estimators`learning_rate!(int[10;100;`prior pykw"uniform"]`;re[.001;1f;`prior pykw"log-uniform"]`);
   `n_estimators`learning_rate!(int[10;100;`prior pykw"uniform"]`;re[.001;1f;`prior pykw"log-uniform"]`);
   `n_estimators`max_depth`criterion!(int[10;100;`prior pykw"uniform"]`;re[1f;100f;`prior pykw"uniform"]`;cat[`gini`entropy]`))

