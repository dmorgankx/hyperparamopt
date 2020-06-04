# hyperparamopt

The purpose of this repository is to act as a base location for the development of kdb+/q hyperparameter optimization functionality.

The repository contains:
- `hpopt_compare.sh` - a bash script which will run the hyperparameter optimization for multiple datasets, across multiple models
- `reshpopt.q` - a q script which takes command line arguments and will run the hyperparameter optimization for a user defined dataset across multiple models and then save results/plots on disk
- `runhpopt.q` - a q script providing the functionality to apply hyperparameter optimization to both single and multiple machine learning models for a given dataset
- `userhp.q` - a q script containing user defined hyperparameters for each model
- `xval_updated.q` - a q script containing an updated version of xval.q contained within the [ML-Toolkit](https://github.com/kxsystems/ml) which allows for grid, random, Sobol-random and Bayesian hyperparameter search

## Running with bash script

The bash script can be run using the below:

```
$ ./hpopt_compare.sh
```

## Running q script with command line arguments

The script `reshpopt.q` can be run using the below, where the user must pass in a file path to the data `fin`, a file path where they would like the outputs to be saved `fout`, the datatypes of the input dataset `dtyp` and the target column `targ`.

```q
$ q reshpopt.q -fin data.csv -fout results -dtyp FFFFFIB -targ x6
Running comparison

Running comparison
Running random search
Running Sobol search
Running Bayesian search
Returing results

Plotting results
Saving results
Comparison complete, see outputs/
```

## Running functions within a q process

To run multiple models which have been predefined in the `userhp.q` script (along with their hyperparameter sets) the below syntax can be used. The user must call the function `.ml.hpopt_mltmodel` and pass in a file path to the data, datatypes of the data as a string and target column as a symbol.

```q
q)\l runhpopt.q
q)fin :"test_data.csv"  / works with any csv containing a kdb table
q)dtyp:"FFFFFIB"
q)targ:`x6
q)r:.ml.hpopt_mltmodel[hsym`$fin;dtyp;targ]
Running comparison
Running random search
Running Sobol search
Running Bayesian search
Returing results
```

To run an individual model the function `.ml.hpopt_sglmodel` is run, where the data, target, grid search scoring function and hyperparameters for grid, random (pseudo and Sobol) and Bayesian must be passed in.

```q
q)\l runhpopt.q
q)data:([]1000?1f;1000?1f;1000?1f;asc 1000?100)
q)targ:asc 1000?0b
// grid search scoring function
q)scf:.ml.xv.fitscore mdl:{.p.import[`sklearn.linear_model]`:SGDClassifier}
// grid search hpgen function
q)gs_01_gen:{l:((0.,(1_til x-1)*10%x-1),10.)%10;(l*z+abs y)+y}
// grid search hyperparams
q)gs:`random_state`average`l1_ratio`alpha!(prms`seed;01b;gs_01_gen[16;0;1];xexp[10]gs_01_gen[32;-5;2])
// random search hyperparams
q)rs:`average`l1_ratio`alpha!(`boolean;(`uniform;0;1;"f");(`loguniform;-5;2;"f"))
// python imports for bayesian hyperparams
q)re :.p.import[`skopt.space]`:Real
q)cat:.p.import[`skopt.space]`:Categorical
q)SGD:.p.import[`sklearn.linear_model]`:SGDClassifier
// bayesian hyperparams
q)bs:`average`l1_ratio`alpha!(cat[01b]`;re[0;1;`prior pykw"uniform"]`;re[1e-005;1e+010;`prior pykw"log-uniform"]`)
// run single model across hyperparam optimization methods
q)r:.ml.hpopt_sglmodel[data;targ;scf;mdl;gs;rs;bs]
Running comparison
Running random search
Running Sobol search
Running Bayesian search
Returing results
q)r
alpha        average fold_score                              l1_ratio  method   random_state time         score
---------------------------------------------------------------------------------------------------------------
0.02438354   0       1       0.99375 0.58125 1       1       0         grid     42           00:00:21.533 1
0.0003729849 0       1       0.99375 0.8125  1       1       0.4863586 random   42           00:00:19.005 1
0.0001647392 0       1       0.975   0.95    1       1       0.3925781 sobol    42           00:00:18.611 1
0.003334776  0       0.95625 1       0.91875 0.99375 0.95625 1         bayesian 42           00:04:14.004 0.98
```