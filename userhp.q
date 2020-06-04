/
In this script we generalize the process of producing hyperparameter sets for different models.
These sets will then be passed to the hpopt_results.q script to run each model and compare results
 across each method of hyperparameter generation.
\
\l xval_updated.q

\d .ml

prms:`seed`k`n`test`trials!(42;5;1;.2;1024);

// starting with classification models
/* lib = library model belongs to, e.g. sklearn, keras, etc.
/* fnc = module the model belongs to
/* mdl = model name
models:([]lib:3#`sklearn;fnc:`linear_model`svm`linear_model;mdl:`SGDClassifier`SVC`LogisticRegression)

// function creates a projection for passing into grid search
pyproj:{{[x;y;z].p.import[x]y}[` sv x`lib`fnc;hsym x`mdl]}

// generate scoring functions
scf:xv.fitscore@/:mdl_import:pyproj each models

// grid hp
gs_01_gen:{l:((0.,(1_til x-1)*10%x-1),10.)%10;(l*z+abs y)+y}
gshp:models[`mdl]!
  (`random_state`average`l1_ratio`alpha!(prms`seed;01b;gs_01_gen[16;0;1];xexp[10]gs_01_gen[32;-5;2]);
   `random_state`C`gamma`kernel!(prms`seed;g;g;`linear`poly`rbf`sigmoid);
   `random_state`penalty`tol`C!(prms`seed;`l1`l2`elasticnet`none;gs_01_gen[16;0;1];g:xexp[10]til[16]-5))

// RANDOM SEARCH
// pseudo- and sobol-random hp
rshp:models[`mdl]!
  (`average`l1_ratio`alpha!(`boolean;(`uniform;0;1;"f");(`loguniform;-5;2;"f"));
   `C`gamma`kernel!((`loguniform;-5;16;"f");(`loguniform;-5;16;"f");(`symbol`linear`poly`rbf`sigmoid));
   `penalty`tol`C!((`symbol`l1`l2`elasticnet`none);(`uniform;0;1;"f");(`loguniform;-5;2;"f")))

// BAYESIAN SEARCH
// import python functions
re :.p.import[`skopt.space]`:Real;
cat:.p.import[`skopt.space]`:Categorical;
SGD:.p.import[`sklearn.linear_model]`:SGDClassifier;
// bayesian hp
bshp:models[`mdl]!
  (`average`l1_ratio`alpha!(cat[01b]`;re[0;1;`prior pykw"uniform"]`;re[1e-005;1e+010;`prior pykw"log-uniform"]`);
   `C`gamma`kernel!(re[.01;100;`prior pykw"log-uniform"]`;re[.01;100;`prior pykw"log-uniform"]`;cat[`linear`poly`rbf`sigmoid]`);
   `penalty`tol`C!(cat[`l1`l2`elasticnet`none]`;re[0;1;`prior pykw"uniform"]`;re[1e-005;1e+010;`prior pykw"log-uniform"]`))