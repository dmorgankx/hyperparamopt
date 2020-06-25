\l xval_updated.q

\d .ml

prms:`seed`k`n`test`trials!(42;5;1;.2;256);

// starting with regression models
/* lib = library model belongs to, e.g. sklearn, keras, etc.
/* fnc = module the model belongs to
/* mdl = model name
lib:2#`sklearn
fnc:2#`ensemble
mdl:`GradientBoostingRegressor`RandomForestRegressor
models:([]lib;fnc;mdl)

// function creates a projection for passing into grid search
pyproj:{{[x;y;z].p.import[x]y}[` sv x`lib`fnc;hsym x`mdl]}

// generate scoring functions
scf:xv.fitscore@/:mdl_import:pyproj each models

// grid hp
gs_01_gen:{l:((0.,(1_til x-1)*10%x-1),10.)%10;(l*z+abs y)+y}
gshp:models[`mdl]!
  (`random_state`n_estimators`max_depth`criterion!(prms`seed;"j"$10*1+til 8;1+til 16;`mae`mse);
   `random_state`n_estimators`max_depth`criterion!(prms`seed;"j"$10*1+til 8;1+til 16;`mae`mse))

// RANDOM SEARCH
// pseudo- and sobol-random hp
rshp:models[`mdl]!
  (`random_state`n_estimators`max_depth`criterion!((`rand;prms`seed);(`uniform;1;100;"j");(`uniform;1;20;"j");(`symbol;`mae`mse));
   `random_state`n_estimators`max_depth`criterion!((`rand;prms`seed);(`uniform;1;100;"j");(`uniform;1;20;"j");(`symbol;`mae`mse)))

// BAYESIAN SEARCH
// import python functions
re :.p.import[`skopt.space]`:Real;
int:.p.import[`skopt.space]`:Integer;
cat:.p.import[`skopt.space]`:Categorical;

// bayesian hp
bshp:models[`mdl]!
  (`n_estimators`max_depth`criterion!(int[10;100;`prior pykw"uniform"]`;int[1;20;`prior pykw"uniform"]`;cat[`mae`mse]`);
   `n_estimators`max_depth`criterion!(int[10;100;`prior pykw"uniform"]`;int[1;20;`prior pykw"uniform"]`;cat[`mae`mse]`))