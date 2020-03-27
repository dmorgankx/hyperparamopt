/* Below is an example of the most generalizable method of hyperopt applicable for kdb+ automl *\

\l p.q

// load in python script with the hyperopt code
\l script3.p

// load in data
iris:.p.import[`sklearn.datasets][`:load_iris][0]`

// example 1 - knn classifier
knn:.p.import[`sklearn.neighbors]`:KNeighborsClassifier

// parameters
/* mdl - python model as a foreign
/* X - features
/* y - targets
/* choice - within hyperopt there are different types of params you can generate, one is choice where a list must be given, the other is uniform (used for SVC) where a range must be given
params:`mdl`X`y`choice!(knn`;iris`data;iris`target;enlist[`n_neighbors]!enlist 1+til 49)
-1"Applying hyperopt to knn\nBest params:";
show best:.p.get[`find_best][params]`

// example 2 - svm classifier
SVC:.p.import[`sklearn.svm;`:SVC]`

// parameters
params:`mdl`X`y`choice`uniform!
  (SVC;iris`data;iris`target;enlist[`kernel]!enlist`linear`sigmoid`poly`rbf;`C`gamma!(0 20;0 20))

// find best params
-1"\nApplying hyperopt to svc\nBest params:";
show best:.p.get[`find_best][params]`