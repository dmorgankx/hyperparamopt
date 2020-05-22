from sklearn.model_selection import cross_val_score
from hyperopt import fmin, tpe, hp, STATUS_OK, Trials

def find_best(params):
    return fmin(f,upd_params(params),algo=tpe.suggest,max_evals=100,trials=trials,show_progressbar=False,return_argmin=True)
    
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
    if 'loguniform' in list(params):
        for key in list(params['loguniform']):
            value = params['loguniform'][key]
            params[key] = hp.uniform(key, value[0], value[1])
        del params['loguniform']
    return params

def f(params):
    X = params['X']
    y = params['y']
    mdl = params['mdl']
    del params['X']
    del params['y']
    del params['mdl']
    return cross_val_score(mdl(**params), X, y).mean()