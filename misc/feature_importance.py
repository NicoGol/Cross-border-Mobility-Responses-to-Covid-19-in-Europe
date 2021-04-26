from models import *
from sklearn.inspection import permutation_importance
import pandas as pd
from sklearn.metrics import mean_absolute_error as mae

def feature_importance(m):
    """
    This function performs a permutation importance on the different features of the model m and stores the results
    in a csv in the data/ranking_NPI folder
    :param m: it is an instance of one of the subclasses of the Model class representing the model to use
    """
    model = m.model()
    model.fit(m.features(), m.target())
    y_pred = model.predict(m.features())
    baseline = mae(m.target(),y_pred)
    features = m.features()
    results = permutation_importance(model, features, m.target(), scoring='neg_mean_absolute_error',n_repeats=10)
    df = pd.DataFrame({'feature_asym':m.features().columns.values.tolist(),'importance_mean':results.importances_mean,
                       'importance_std':results.importances_std})

    df.columns = df.columns.get_level_values(0)
    df['mae_baseline'] = baseline

    path = "../output/feature_importance/"+m.name.replace('*','')+".csv"
    df.to_csv(path)

#list of basic models (without PCA or lag)
models =  [LinearModel(),LinearModel(FE=['pair_id']),LinearModel(FE=['date']),LinearModel(FE=['date','pair_id']),
          KNNModel(),KNNModel(FE=['pair_id']),KNNModel(FE=['date']),KNNModel(FE=['date','pair_id']),
          GradientBoostingModel(),GradientBoostingModel(FE=['pair_id']),GradientBoostingModel(FE=['date']),
          GradientBoostingModel(FE=['date','pair_id']),
          MLPModel(),MLPModel(FE=['pair_id']),MLPModel(FE=['date']),MLPModel(FE=['date','pair_id'])]

#list of models with a 2 component PCA
models_pca = [LinearModel(pca=2),LinearModel(FE=['pair_id'],pca=2),LinearModel(FE=['date'],pca=2),LinearModel(FE=['date','pair_id'],pca=2),
              KNNModel(pca=2),KNNModel(FE=['pair_id'],pca=2),KNNModel(FE=['date'],pca=2),KNNModel(FE=['date','pair_id'],pca=2),
              GradientBoostingModel(pca=2),GradientBoostingModel(FE=['pair_id'],pca=2),GradientBoostingModel(FE=['date'],pca=2),
              GradientBoostingModel(FE=['date','pair_id'],pca=2),
              MLPModel(pca=2),MLPModel(FE=['pair_id'],pca=2),MLPModel(FE=['date'],pca=2),MLPModel(FE=['date','pair_id'],pca=2)]

#list of models with lags
models_lags = [LinearModel(FE=['pair_id'],lags=True),LinearModel(FE=['date','pair_id'],lags=True),
              KNNModel(FE=['pair_id'],lags=True),KNNModel(FE=['date','pair_id'],lags=True),
              GradientBoostingModel(FE=['pair_id'],lags=True),GradientBoostingModel(FE=['date','pair_id'],lags=True),
              MLPModel(FE=['pair_id'],lags=True),MLPModel(FE=['date','pair_id'],lags=True)]

for model in models:
    feature_importance(model)
