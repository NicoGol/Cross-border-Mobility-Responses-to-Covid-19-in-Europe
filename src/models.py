from model import Model
from data import get_Xy
from sklearn.neighbors import KNeighborsRegressor
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.linear_model import LinearRegression


class LinearModel(Model):
    """
    This class is the subclasse of the Model class corresponding to the Linear Regressor.
    """

    def __init__(self,omega=True,IV=[],pca=0,lags=False):
        self.name = "Linear"
        if omega:
            self.name += "*"
        for ele in IV:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = IV
        (self.X, self.y) = get_Xy(omega=omega,pca=pca,add_lags=lags)

    def regression_model(self):
        return LinearRegression(fit_intercept=False)

class KNNModel(Model):
    """
    This class is the subclasse of the Model class corresponding to the K Neighbors Regressor.
    """

    def __init__(self, omega=True, IV=[], pca=0,lags=False):
        self.name = "KNN"
        if omega:
            self.name += "*"
        for ele in IV:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = IV
        (self.X, self.y) = get_Xy(omega=omega, pca=pca,add_lags=lags)

    def regression_model(self):
        return KNeighborsRegressor(n_neighbors=3,weights='distance')



class GradientBoostingModel(Model):
    """
    This class is the subclasse of the Model class corresponding to the Gradient Boosting Regressor.
    """

    def __init__(self, omega=True, IV=[], pca=0,lags=False):
        self.name = "G-Boost"
        if omega:
            self.name += "*"
        for ele in IV:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = IV
        (self.X, self.y) = get_Xy(omega=omega, pca=pca,add_lags=lags)

    def regression_model(self):
        return GradientBoostingRegressor(max_depth=5,n_estimators=100)


class MLPModel(Model):
    """
    This class is the subclasse of the Model class corresponding to the Multi-Layer Perceptron Regressor.
    """

    def __init__(self, omega=True, IV=[], pca=0,lags=False):
        self.name = "MLP"
        if omega:
            self.name += "*"
        for ele in IV:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = IV
        (self.X, self.y) = get_Xy(omega=omega, pca=pca,add_lags=lags)

    def regression_model(self):
        return MLPRegressor(hidden_layer_sizes=[200,200],batch_size=50)
