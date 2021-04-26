from data import get_Xy
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder
from sklearn.preprocessing import MinMaxScaler




class Model:
    """
    This is the abstract base class representing the different models described in the paper.
        - self.name is the name of the model
        - self.cat is a list containing the indicator variables the model will use (pair_id is for the corridor
    indicator variable and date is for the day indicator variable)
        - self.X is the pandas Dataframe of size (n_samples,n_features) corresponding to the training data. The columns
    are the different input features used in the training and the rows are the set of observations the model will be
    trained with.
        - self.y is the pandas DataFrame of size (n_samples,1) corresponding to the target variable (the traffic growth
    rate). The rows are the same set of observations as in self.X
        - model(self) is the method returning the sklearn model with the appropriate pipeline steps applied
        - preprocessor(self) is the method returning the set of transformer preprocess steps that needs to be applied
    to the model
        - regression_model(self) returns the sklearn model corresponding to one of the approaches described in the paper
        - features(self) returns the set of input features self.X which needs to be learned by the model
        - target(self) returns the values of the target variable (traffic growth rate) on which the model is trained
    """

    def __init__(self, omega=True, IV=[], pca=0, lags=False):
        """
        This method is the base constructor of the Model class
        :param omega: if set to true, the version with the directive priors (weights omega) of the training data is used
        :param IV: the set of indicator variable to use for this model (pair_id for the corridor
        indicator variable and date for the day indicator variable)
        :param pca: if not null, a PCA is conducted on each of the policy measure features set (one for each country).
        The value of the pca parameter represents the number of PCA component to be use instead of the corresponding
        variables.
        :param lags: if set to True, four  new  country-specific features are inserted in addition to the initial ones:
        lags of 7 and 14 days of new Covid cases and deaths are included.
        """

        self.name = "Abstract Model"
        if omega:
            self.name += "*"
        for ele in IV:
            self.name += "_" + ele
        if pca > 0:
            self.name += "_PCA_" + str(pca)
        self.cat = IV
        (self.X, self.y) = get_Xy(omega=omega, pca=pca, add_lags=lags)

    def model(self):
        """
        This method returns the sklearn model with the set of preprocess steps that will be train with self.X and self.y
        :return: This methods returns a sklearn pipeline with 2 steps :
            1. the preprocessing step defined byt the preprocessor method
            2. the sklearn regression model that is defined in the subclasses
        """

        reg = Pipeline(steps=[('preprocessor', self.preprocessor()),
                                  ('regression', self.regression_model())])
        return reg

    def preprocessor(self):
        """
        This method returns the set of transformer preprocess steps that needs to be applied to the model
        :return: a sklearn ColumnTransformer that drops the unused features, scales the numerical features with a
        MinMax Scaler and transforms the categorical features (corridor and day variables) in one hot encoders
        """

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

    def regression_model(self):
        """
        This methods returns the model corresponding to concerned approach. This method will be overwrite
        by the subclasses.
        :return: One of the following sklearn regression models: LinearRegressor, KNeighborsRegressor,
        GradientBoostingRegressor or MLPRegressor with already tuned parameters
        """

        return None

    def features(self):
        """
        This method returns self.X, the pandas Dataframe corresponding to the training data.
        :return: a pandas Dataframe of size (n_samples,n_features)
        """

        return self.X

    def target(self):
        """
        This method returns self.y, the pandas Dataframe corresponding to the target variable.
        :return: a pandas Dataframe of size (n_samples,1)
        """

        return self.y

    def name(self):
        """
        This method returns the name of the model.
        :return: a string corresponding to the name of the model
        """

        return self.name





