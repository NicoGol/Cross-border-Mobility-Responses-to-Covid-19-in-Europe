from models import *

from sklearn import model_selection
from latextable import *

#List of models to compare the different approaches with and without directive priors
models1 = [LinearModel(omega=False,FE=['pair_id','date']),LinearModel(FE=['pair_id','date']),
          KNNModel(omega=False,FE=['pair_id','date']),KNNModel(FE=['pair_id','date']),
          GradientBoostingModel(omega=False,FE=['pair_id','date']),GradientBoostingModel(FE=['pair_id','date']),
          MLPModel(omega=False,FE=['pair_id','date']),MLPModel(FE=['pair_id','date'])]

#List of models to compare the different approaches with and without corridor and day indicator variables
models2 = [LinearModel(),LinearModel(FE=['pair_id']),LinearModel(FE=['date']),LinearModel(FE=['pair_id','date']),
          KNNModel(),KNNModel(FE=['pair_id']),KNNModel(FE=['date']),KNNModel(FE=['pair_id','date']),
          GradientBoostingModel(),GradientBoostingModel(FE=['pair_id']),GradientBoostingModel(FE=['date']),GradientBoostingModel(FE=['pair_id','date']),
          MLPModel(),MLPModel(FE=['pair_id']),MLPModel(FE=['date']),MLPModel(FE=['pair_id','date'])]


def evaluate_error(models):
    """
    This function evaluates the given models by performing a 10-fold cross validation. It displays and returns the
    results in a form of a matrix.
    :param models: list of size (n_models) containing instances of the Model subclasses
    :return: a matrix of size (4,n_models) where the rows represents the models and the columns the different metrics.
    """
    res = []
    res.append(["Model", "avg MAE", "std MAE", "avg RMSE", "std RMSE"])
    for m in models:
        print("---------------------")
        print("model:", m.name)

        kfold = model_selection.KFold(n_splits=10, random_state=7, shuffle=True)

        def score(scoring):
            results = model_selection.cross_val_score(m.model(), m.features(), m.target(), cv=kfold, scoring=scoring)
            return (-results.mean(), results.std())

        (mae, std_mae) = score('neg_mean_absolute_error')
        (rmse, std_rmse) = score('neg_root_mean_squared_error')

        print("MAE: %.3f (%.3f)" % (mae, std_mae))
        print("RMSE: %.3f (%.3f)" % (rmse, std_rmse))

        res.append([m.name, mae, std_mae, rmse, std_rmse])

    table = Texttable()
    table.set_cols_align(["l", "r", "c", "r", "c"])
    table.set_cols_valign(["t", "m", "b", "m", "b"])
    table.add_rows(res)

    print(table.draw() + "\n")

    print(draw_latex(table, caption="Model Error Comparison"))

    return res

#compare the models with and without directive priors
res_prior = evaluate_error(models1)

#compare the models with and without day and corridor indicator variables
res_IV = evaluate_error(models2)