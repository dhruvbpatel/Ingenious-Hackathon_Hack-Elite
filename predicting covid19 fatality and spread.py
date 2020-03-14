#!/usr/bin/env python
# coding: utf-8

# In[49]:


import numpy as np
import pandas as pd 
import seaborn as sns
import matplotlib.pyplot as plt

get_ipython().run_line_magic('matplotlib', 'inline')


import matplotlib.dates as mdates
import plotly.express as px
from datetime import date, timedelta
from sklearn.cluster import KMeans
from fbprophet import Prophet
from fbprophet.plot import plot_plotly, add_changepoints_to_plot
import plotly.offline as py
from statsmodels.tsa.arima_model import ARIMA
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
import statsmodels.api as sm
from keras.models import Sequential
from keras.layers import LSTM,Dense
from keras.layers import Dropout
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.preprocessing.sequence import TimeseriesGenerator


# In[50]:



path = '../input/coronavirusdataset/'


patient_data_path = path + 'patient.csv'
route_data_path = path + 'route.csv'
time_data_path = path + 'time.csv'


df_patient =pd.read_csv(patient_data_path)

df_route = pd.read_csv(route_data_path)
df_time = pd.read_csv(time_data_path)


# In[51]:


df_patient.head()


# In[52]:


df_patient.info()


# In[53]:


df_patient.describe()


# In[54]:


df_patient.groupby('country').count()


# In[55]:


df_patient.columns


# In[56]:


df_patient.isna().sum()


# In[57]:


df_patient.birth_year.unique()


# In[58]:


### we can add a new columns for age 


# In[59]:


df_patient[df_patient['birth_year']<0] 


# In[60]:



df_patient['birth_year'].isnull().count()


# In[61]:


df_patient['birth_year']=df_patient['birth_year'].fillna(np.nan,inplace=True)


# In[62]:


## now forming age column 

df_patient['age'] = 2020 - df_patient['birth_year']  ## create an age column 


# In[63]:


## now splitting the data into age groups

import math
def group_age(age):
    if age >= 0: # not NaN
        if age % 10 != 0:
            lower = int(math.floor(age / 10.0)) * 10
            upper = int(math.ceil(age / 10.0)) * 10 - 1
            return f"{lower}-{upper}"
        else:
            lower = int(age)
            upper = int(age + 9) 
            return f"{lower}-{upper}"
    return "Unknown"


df_patient["age_range"] = df_patient["age"].apply(group_age)


# In[64]:


df_patient['age_range']


# In[65]:


patient=df_patient


# In[66]:


date_cols = ["confirmed_date", "released_date", "deceased_date"] ## into datetime format
for col in date_cols:
    patient[col] = pd.to_datetime(patient[col])


# In[67]:


patient.head()


# In[68]:


patient.infected_by.unique()


# In[69]:


patient["time_to_release_since_confirmed"] = patient["released_date"] - patient["confirmed_date"]
patient["time_to_death_since_confirmed"] = patient["deceased_date"] - patient["confirmed_date"]
patient["duration_since_confirmed"] = patient[["time_to_release_since_confirmed", "time_to_death_since_confirmed"]].min(axis=1)
patient["duration_days"] = patient["duration_since_confirmed"].dt.days
age_ranges = sorted(set([ar for ar in patient["age_range"] if ar != "Unknown"]))
patient["state_by_gender"] = patient["state"] + "_" + patient["sex"]
released = df_patient[df_patient.state == 'released']
isolated_state = df_patient[df_patient.state == 'isolated']
dead = df_patient[df_patient.state == 'deceased']


# **Confirmed Cases**

# In[70]:


clus=df_route.loc[:,['id','latitude','longitude']]
clus.head(10)


# **Checking for number of cluster**

# In[71]:


K_clusters = range(1,8)
kmeans = [KMeans(n_clusters=i) for i in K_clusters]
Y_axis = df_route[['latitude']]
X_axis = df_route[['longitude']]
score = [kmeans[i].fit(Y_axis).score(Y_axis) for i in range(len(kmeans))]
plt.plot(K_clusters, score)
plt.xlabel('Number of Clusters')
plt.ylabel('Score')
plt.show()


# As in this graph, after 4 score go to constant value, so we will go with 4 clusters

# **K-Mean Clusterning**

# In[72]:


kmeans = KMeans(n_clusters = 4, init ='k-means++')
kmeans.fit(clus[clus.columns[1:3]])
clus['cluster_label'] = kmeans.fit_predict(clus[clus.columns[1:3]])
centers = kmeans.cluster_centers_
labels = kmeans.predict(clus[clus.columns[1:3]])


# **Graphical representation of clusters**

# In[73]:


clus.plot.scatter(x = 'latitude', y = 'longitude', c=labels, s=50, cmap='viridis')
plt.scatter(centers[:, 0], centers[:, 1], c='black', s=100, alpha=0.5)


# In[74]:


data = daily_count.resample('D').first().fillna(0).cumsum()
data = data[20:]
x = np.arange(len(data)).reshape(-1, 1)
y = data.values


# **Regression Model**

# In[75]:


from sklearn.neural_network import MLPRegressor
model = MLPRegressor(hidden_layer_sizes=[32, 32, 10], max_iter=50000, alpha=0.0005, random_state=26)
_=model.fit(x, y)


# In[ ]:


test = np.arange(len(data)+7).reshape(-1, 1)
pred = model.predict(test)
prediction = pred.round().astype(int)
week = [data.index[0] + timedelta(days=i) for i in range(len(prediction))]
dt_idx = pd.DatetimeIndex(week)
predicted_count = pd.Series(prediction, dt_idx)


# **Graphical representatoin of current confirmed and predicted confirmed**

# In[ ]:


accumulated_count.plot()
predicted_count.plot()
plt.title('Prediction of Accumulated Confirmed Count')
plt.legend(['current confirmd count', 'predicted confirmed count'])
plt.show()


# **Prophet**

# **Making data ready for Prophet**

# In[ ]:


prophet= pd.DataFrame(data)
prophet
pr_data = prophet.reset_index()
pr_data.columns = ['ds','y']
pr_data


# **Model and prediction**

# In[ ]:


m=Prophet()
m.fit(pr_data)
future=m.make_future_dataframe(periods=365)
forecast=m.predict(future)
forecast


# **Graphical Representation of Prediction**

# In[ ]:


fig = plot_plotly(m, forecast)
py.iplot(fig) 

fig = m.plot(forecast,xlabel='Date',ylabel='Confirmed Count')


# In[ ]:


figure=m.plot_components(forecast)


# **Autoregressive integrated moving average(Arima)**

# **Making data ready for Arima**

# In[ ]:


confirm_cs = prophet.cumsum()
arima_data = confirm_cs.reset_index()
arima_data.columns = ['confirmed_date','count']
arima_data


# ** Model and prediction**

# In[ ]:


model = ARIMA(arima_data['count'].values, order=(1, 2, 1))
fit_model = model.fit(trend='c', full_output=True, disp=True)
fit_model.summary()


# **Graphical Representation for Prediction**

# In[ ]:


fit_model.plot_predict()
plt.title('Forecast vs Actual')
pd.DataFrame(fit_model.resid).plot()


# Forcast for next 6 days

# In[ ]:


forcast = fit_model.forecast(steps=6)
pred_y = forcast[0].tolist()
pd.DataFrame(pred_y)


# **LSTM**

# In[ ]:


dataset = pd.DataFrame(data)
dataset.columns = ['Confirmed']
dataset.head()


# In[ ]:


data = np.array(dataset).reshape(-1, 1)
train_data = dataset[:len(dataset)-5]
test_data = dataset[len(dataset)-5:]


# In[ ]:


scaler = MinMaxScaler()
scaler.fit(train_data)
scaled_train_data = scaler.transform(train_data)
scaled_test_data = scaler.transform(test_data)
n_input =5
n_features =1
                             
generator = TimeseriesGenerator(scaled_train_data,scaled_train_data, length=n_input, batch_size=1)

lstm_model = Sequential()
lstm_model.add(LSTM(units = 50, return_sequences = True, input_shape = (n_input, n_features)))
lstm_model.add(Dropout(0.2))
lstm_model.add(LSTM(units = 50, return_sequences = True))
lstm_model.add(Dropout(0.2))
lstm_model.add(LSTM(units = 50))
lstm_model.add(Dropout(0.2))
lstm_model.add(Dense(units = 1))
lstm_model.compile(optimizer = 'adam', loss = 'mean_squared_error')
lstm_model.fit(generator, epochs = 30)


# In[ ]:


lstm_model.history.history.keys()


# In[ ]:


losses_lstm = lstm_model.history.history['loss']
plt.figure(figsize = (30,4))
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.xticks(np.arange(0,100,1))
plt.plot(range(len(losses_lstm)), losses_lstm)


# In[ ]:


lstm_predictions_scaled = []

batch = scaled_train_data[-n_input:]
current_batch = batch.reshape((1, n_input, n_features))

for i in range(len(test_data)):   
    lstm_pred = lstm_model.predict(current_batch)[0]
    lstm_predictions_scaled.append(lstm_pred) 
    current_batch = np.append(current_batch[:,1:,:],[[lstm_pred]],axis=1)


# In[ ]:


prediction = pd.DataFrame(scaler.inverse_transform(lstm_predictions_scaled))
prediction.head()


# In[ ]:




