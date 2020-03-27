from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.model_selection import cross_val_score
from hyperopt import STATUS_OK

def f(params):
    feat = params['X']
    targ = params['y']
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
    acc = cross_val_score(clf, feat, targ).mean()
    return {'loss': -acc, 'status': STATUS_OK}