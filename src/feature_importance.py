from models import *
from sklearn.inspection import permutation_importance
import pandas as pd
from sklearn.metrics import mean_absolute_error as mae

def feature_importance(m):
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

    path = "../data/ranking_NPI/"+m.name.replace('*','')+".csv"
    df.to_csv(path)

models = [LinearModel(),LinearModel(FE=['pair_id']),LinearModel(FE=['date']),LinearModel(FE=['date','pair_id']),LinearModel(pca=3)]
          #KNNModel(),KNNModel(FE=['pair_id']),KNNModel(FE=['date']),KNNModel(FE=['date','pair_id']),KNNModel(pca=3),
          #GradientBoostingModel(),GradientBoostingModel(FE=['pair_id']),GradientBoostingModel(FE=['date']),
          #GradientBoostingModel(FE=['date','pair_id']),GradientBoostingModel(pca=3),
          #MLPModel(),MLPModel(FE=['pair_id']),MLPModel(FE=['date']),MLPModel(FE=['date','pair_id']),MLPModel(pca=3)]

for model in models:
    feature_importance(model)
