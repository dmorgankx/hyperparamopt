# hyperparamopt

The purpose of this repository is to act as a base location for the development of kdb+/q hyperparameter optimization functionality.

The functions contained within the main script `hpopt_results.q` can be run using the below. Note a that the functions must be run using the same `param` variable as specified below. This will be updated in further versions.

### `.ml.save_hpopt_res` 

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

### `.ml.load_hpopt_res`

```
alpha        average fold_score                              l1_ratio  method   random_state time         score
---------------------------------------------------------------------------------------------------------------
0.02438354   0       1       0.99375 0.58125 1       1       0         grid     42           00:00:21.533 1
0.0003729849 0       1       0.99375 0.8125  1       1       0.4863586 random   42           00:00:19.005 1
0.0001647392 0       1       0.975   0.95    1       1       0.3925781 sobol    42           00:00:18.611 1
0.003334776  0       0.95625 1       0.91875 0.99375 0.95625 1         bayesian 42           00:04:14.004 0.98
```