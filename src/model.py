from data import get_Xy
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder

from sklearn.preprocessing import MinMaxScaler
class Model:
    def __init__(self,name="Model"):
        self.name = name
        self.cat = ['pair_id','date']
        (self.X, self.y) = get_Xy()

    def model(self):
        reg = Pipeline(steps=[('preprocessor', self.preprocessor()),
                                  ('regression', self.regression_model())])
        return reg

    def preprocessor(self):
        numeric_features = self.features().columns.values.tolist()
        dummies = ['pair_id','date']
        for d in dummies:
            numeric_features.remove(d)
        numeric_transformer = Pipeline(steps=[
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', MinMaxScaler())])

        categorical_features = self.cat
        features_to_drop = [x for x in dummies if x not in self.cat]
        categorical_transformer = OneHotEncoder(handle_unknown='ignore')
        preprocessor = ColumnTransformer(
            transformers=[
                ('num', numeric_transformer, numeric_features),
                ('clmn_drpr','drop',features_to_drop),
                ('cat', categorical_transformer, categorical_features)])
        return preprocessor

    def features(self):
        return self.X

    def target(self):
        return self.y

    def name(self):
        return self.name





