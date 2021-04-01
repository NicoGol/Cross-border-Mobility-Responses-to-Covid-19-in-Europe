import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import LabelEncoder

#print(sklearn.__version__)
features_without_omega = ['pair_id','date','new_cases_smoothed_pm_raw_i',
            'new_deaths_smoothed_pm_raw_i','new_cases_smoothed_pm_raw_j',
            'new_deaths_smoothed_pm_raw_j','c1_schoolclosing_ma_i', 'c1_schoolclosing_ma_j',
            'c2_workplaceclosing_ma_i', 'c2_workplaceclosing_ma_j',
            'c3_cancel_events_ma_i', 'c3_cancel_events_ma_j', 'c4_restr_gather_ma_i',
            'c4_restr_gather_ma_j', 'c5_close_transp_ma_i',
            'c5_close_transp_ma_j', 'c6_stay_home_ma_i', 'c6_stay_home_ma_j',
            'c7_restr_move_ma_i', 'c7_restr_move_ma_j',
            'c8_int_trvl_controls_ma_i', 'c8_int_trvl_controls_ma_j',
            'h2_testingpolicy_ma_i', 'h2_testingpolicy_ma_j',
            'h3_contacttracing_ma_i', 'h3_contacttracing_ma_j']



features_with_omega = ['pair_id','date','new_cases_smoothed_pm_i_wji_ac',
                         'new_deaths_smoothed_pm_i_wji_ac','new_cases_smoothed_pm_j_wji_ac',
                         'new_deaths_smoothed_pm_j_wji_ac', 'c1_schoolclosing_ma_i_wji_ac',
                         'c1_schoolclosing_ma_j_wji_ac', 'c2_workplaceclosing_ma_i_wji_ac',
                         'c2_workplaceclosing_ma_j_wji_ac', 'c3_cancel_events_ma_i_wji_ac',
                         'c3_cancel_events_ma_j_wji_ac', 'c4_restr_gather_ma_i_wji_ac',
                         'c4_restr_gather_ma_j_wji_ac', 'c5_close_transp_ma_i_wji_ac',
                         'c5_close_transp_ma_j_wji_ac', 'c6_stay_home_ma_i_wji_ac',
                         'c6_stay_home_ma_j_wji_ac', 'c7_restr_move_ma_i_wji_ac',
                         'c7_restr_move_ma_j_wji_ac', 'c8_int_trvl_controls_ma_i_wji_ac',
                         'c8_int_trvl_controls_ma_j_wji_ac',  'h2_testingpolicy_ma_i_wji_ac',
                         'h2_testingpolicy_ma_j_wji_ac', 'h3_contacttracing_ma_i_wji_ac',
                         'h3_contacttracing_ma_j_wji_ac']

features_name_asymmetric = ['pair_id','date','new_cases_per_million_i',
                        'new_deaths_per_million_i','new_cases_per_million_j',
                        'new_deaths_per_million_j', 'c1_schoolclosing_i',
                         'c1_schoolclosing_j', 'c2_workplaceclosing_i',
                         'c2_workplaceclosing_j', 'c3_cancel_events_i',
                         'c3_cancel_events_j', 'c4_restr_gather_i',
                         'c4_restr_gather_j', 'c5_closepublictransport_i',
                         'c5_closepublictransport_j', 'c6_stay_home_i',
                         'c6_stay_home_j', 'c7_restr_internal_move_i',
                         'c7_restr_internal_move_j', 'c8_int_trvl_controls_i',
                         'c8_int_trvl_controls_j','h2_testingpolicy_i',
                         'h2_testingpolicy_j', 'h3_contacttracing_i',
                         'h3_contacttracing_j']

features_name = ['pair_id','date','new_cases_per_million','new_deaths_per_million',
                 'c1_schoolclosing', 'c2_workplaceclosing', 'c3_cancel_events', 'c4_restr_gather', 'c5_closepublictransport', 'c6_stay_home',
                 'c7_restr_internal_move', 'c8_int_trvl_controls','h2_testingpolicy','h3_contacttracing']

def remove_outliers_and_divide_baseline(df_cont):
  df_cont.insert(5,'traffic_baseline',0.0)
  df_cont = df_cont.drop(df_cont[df_cont.pairname.isin(['Croatia Hungary', 'Hungary Slovenia', 'Finland Norway'])].index)
  for pairname in df_cont.pairname.unique():
    data = df_cont[df_cont.pairname == pairname]
    baseline = data[data.date=='2020-02-29']['max_travel_ma'].values[0]
    if baseline != 0.0:
      df_cont.loc[data.index,'traffic_baseline'] = baseline
    else:
      df_cont = df_cont.drop(data.index)
  df_cont['traffic_growth'] = (df_cont['max_travel_ma'] - df_cont['traffic_baseline'])/ df_cont['traffic_baseline']
  return df_cont



def get_Xy(omega=False,pca=0):
    fb_df = pd.read_csv("../data/fb_with_omegas.csv")
    fb_df = fb_df.rename(columns={'id': 'pair_id', 't': 'date'})
    d_months = {'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04', 'may': '05', 'jun': '06', 'jul': '07', 'aug': '08',
                'sep': '09',
                'oct': '10', 'nov': '11', 'dec': '12'}
    fb_df['date'] = fb_df.date.apply(lambda s: s[-4:] + '-' + d_months[s[2:5]] + '-' + s[:2])
    fb_df = fb_df[fb_df.date >= '2020-02-29']
    fb_df = remove_outliers_and_divide_baseline(fb_df)
    integers = LabelEncoder().fit_transform(fb_df.pair_id)
    fb_df.pair_id = integers
    fb_df_traffic_growth = fb_df['traffic_growth']
    features = features_without_omega
    if omega :
        features = features_with_omega
    fb_df_input = fb_df[features].fillna(0.0)


    fb_df_input.columns = features_name_asymmetric
    data_double = fb_df_input.copy()
    for col in features_name[2:]:
        data_double[col+'_j'] = fb_df_input[col+'_i']
        data_double[col + '_i'] = fb_df_input[col + '_j']
    fb_df_input = fb_df_input.append(data_double)
    traffic_double = fb_df_traffic_growth.copy()
    fb_df_traffic_growth = fb_df_traffic_growth.append(traffic_double)
    X = fb_df_input
    y = fb_df_traffic_growth
    if pca > 0:
        cols  = ['c1_schoolclosing', 'c2_workplaceclosing',
                 'c3_cancel_events', 'c4_restr_gather',
                 'c5_closepublictransport', 'c6_stay_home',
                 'c7_restr_internal_move', 'c8_int_trvl_controls','h2_testingpolicy', 'h3_contacttracing']
        new_X = X[['pair_id','date','new_cases_per_million_i',
               'new_deaths_per_million_i','new_cases_per_million_j',
                'new_deaths_per_million_j']]
        for k in ['_i','_j']:
            X_C = X[[name + k for name in cols]]

            pca_C = PCA(n_components=pca)
            X_C = pca_C.fit_transform(X_C)

            for i in range(pca):
                new_X.loc[:,'Component_'+str(i)] = X_C[:,i]
        X = new_X
    return X,y



