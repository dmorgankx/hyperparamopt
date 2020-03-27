from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.model_selection import cross_val_score
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials

def find_best(params):
    return fmin(f,upd_params(params),algo=tpe.suggest,max_evals=100,trials=Trials())
    
def upd_params(params):
    if 'uniform' in list(params):
        for key in list(params['uniform']):
            value = params['uniform'][key]
            params[key] = hp.uniform(key, value[0], value[1])
        del params['uniform']
    if 'choice' in list(params):
        for key in list(params['choice']):
            params[key] = hp.choice(key, params['choice'][key])
        del params['choice']
    return params

def f(params):
    X = params['X']
    y = params['y']
    del params['X']
    del params['y']
    if params['clf'] == 'KNeighborsClassifier':
        del params['clf']
        clf = KNeighborsClassifier(**params)
    elif params['clf'] == 'SVC':
        del params['clf']
        clf = SVC(**params)
    else:
        return 0
    return cross_val_score(clf, X, y).mean()