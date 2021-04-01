from model import Model
from data import get_Xy
from sklearn.neighbors import KNeighborsRegressor
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.linear_model import LinearRegression


class LinearModel(Model):
    def __init__(self,omega=True,FE=[],pca=0):
        self.name = "Linear"
        if omega:
            self.name += "*"
        for ele in FE:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = FE
        (self.X, self.y) = get_Xy(omega=omega,pca=pca)
    def regression_model(self):
        return LinearRegression(fit_intercept=False)

class KNNModel(Model):

    def __init__(self, omega=True, FE=[], pca=0):
        self.name = "KNN"
        if omega:
            self.name += "*"
        for ele in FE:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = FE
        (self.X, self.y) = get_Xy(omega=omega, pca=pca)
    def regression_model(self):
        return KNeighborsRegressor(n_neighbors=3,weights='distance')



class GradientBoostingModel(Model):
    def __init__(self, omega=True, FE=[], pca=0):
        self.name = "G-Boost"
        if omega:
            self.name += "*"
        for ele in FE:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = FE
        (self.X, self.y) = get_Xy(omega=omega, pca=pca)
    def regression_model(self):
        return GradientBoostingRegressor(max_depth=5,n_estimators=500)


class MLPModel(Model):
    def __init__(self, omega=True, FE=[], pca=0):
        self.name = "MLP"
        if omega:
            self.name += "*"
        for ele in FE:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = FE
        (self.X, self.y) = get_Xy(omega=omega, pca=pca)
    def regression_model(self):
        return MLPRegressor(hidden_layer_sizes=[200,200],batch_size=50)
