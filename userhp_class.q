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
lib:5#`sklearn
fnc:`svm,`linear_model,3#`ensemble
mdl:`SVC`SGDClassifier`AdaBoostClassifier`GradientBoostingClassifier`RandomForestClassifier
models:([]lib;fnc;mdl)

// function creates a projection for passing into grid search
pyproj:{{[x;y;z].p.import[x]y}[` sv x`lib`fnc;hsym x`mdl]}

// generate scoring functions
scf:xv.fitscore@/:mdl_import:pyproj each models

// grid hp
gs_01_gen:{l:((0.,(1_til x-1)*10%x-1),10.)%10;(l*z+abs y)+y}
gshp:models[`mdl]!
  (`random_state`C`gamma`kernel!(prms`seed;g;g:xexp[10]til[16]-5;`linear`poly`rbf`sigmoid);
   `random_state`average`l1_ratio`alpha!(prms`seed;01b;gs_01_gen[16;0;1];xexp[10]gs_01_gen[32;-5;2]);
   `random_state`n_estimators`learning_rate!(prms`seed;"j"$10*1+til 8;xexp[10]gs_01_gen[16;-3;0]);
   `random_state`n_estimators`learning_rate!(prms`seed;"j"$10*1+til 8;xexp[10]gs_01_gen[16;-3;0]);
   `random_state`n_estimators`learning_rate!(prms`seed;"j"$10*1+til 8;xexp[10]gs_01_gen[16;-3;0])
  )

// RANDOM SEARCH
// pseudo- and sobol-random hp
rshp:models[`mdl]!
  (`random_state`C`gamma`kernel!((`rand;prms`seed);(`loguniform;-2;5;"f");(`loguniform;-2;5;"f");(`symbol;`linear`poly`sigmoid));
   `random_state`average`l1_ratio`alpha!((`rand;prms`seed);`boolean;(`uniform;0;1;"f");(`loguniform;-5;2;"f"));
   `random_state`n_estimators`learning_rate!((`rand;prms`seed);(`uniform;1;2;"j");(`loguniform;-5;2;"f"));
   `random_state`n_estimators`learning_rate!((`rand;prms`seed);(`uniform;1;2;"j");(`loguniform;-5;2;"f"));
   `random_state`n_estimators`learning_rate!((`rand;prms`seed);(`uniform;1;2;"j");(`loguniform;-5;2;"f"))
  )

// BAYESIAN SEARCH
// import python functions
re :.p.import[`skopt.space]`:Real;
int:.p.import[`skopt.space]`:Integer;
cat:.p.import[`skopt.space]`:Categorical;

// bayesian hp
bshp:models[`mdl]!
  (`C`gamma`kernel!(re[.01;100;`prior pykw"log-uniform"]`;re[.01;100;`prior pykw "log-uniform"]`;cat[`linear`poly`rbf`sigmoid]`);
   `average`l1_ratio`alpha!(cat[01b]`;re[0;1;`prior pykw"uniform"]`;re[1e-005;1f;`prior pykw"log-uniform"]`);
   `n_estimators`learning_rate!(int[10;100;`prior pykw "uniform"]`;re[1e-005;1f;`prior pykw"log-uniform"]`);
   `n_estimators`learning_rate!(int[10;100;`prior pykw "uniform"]`;re[1e-005;1f;`prior pykw"log-uniform"]`);
   `n_estimators`learning_rate!(int[10;100;`prior pykw "uniform"]`;re[1e-005;1f;`prior pykw"log-uniform"]`)
  )