# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Write directly to the app
st.title("Payments in 2021")

# Get the current credentials and run query
session = get_active_session()
query = "select payment_date, amount_spent from payments_by_date"
created_dataframe = session.sql(query)

# Set variables
queried_data = created_dataframe.to_pandas()
min_date = queried_data['PAYMENT_DATE'].min()
max_date = queried_data['PAYMENT_DATE'].max()

# Use an interactive slider to get min and max dates
min_date_slider = st.slider(
    "Select min date",
    min_value=min_date,
    max_value=max_date,
    value=min_date
)

max_date_slider = st.slider(
    "Select max date",
    min_value=min_date,
    max_value=max_date,
    value=max_date
)

filtered_data = queried_data[(queried_data['PAYMENT_DATE'] >= min_date_slider) 
& (queried_data['PAYMENT_DATE'] <= max_date_slider)]

# Create a simple bar chart
st.line_chart(data=filtered_data, x="PAYMENT_DATE", y="AMOUNT_SPENT")
