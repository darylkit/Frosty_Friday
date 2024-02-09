# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

# Get the current credentials
session = get_active_session()

def get_table_list(selected_schema):
    if selected_schema == "WORLD_BANK_ECONOMIC_INDICATORS":
        return ["COUNTRY_METADATA"]
    elif selected_schema == "WORLD_BANK_METADATA":
        return ["GDP","GOV_EXPENDITURE"]
    elif selected_schema == "WORLD_BANK_SOCIAL_INDIACTORS":
        return ["LIFE_EXPECTANCY","ADULT_LITERACY_RATE","PROGRESSION_TO_SECONDARY_SCHOOL"]
    else:
        return []

with st.sidebar:
        st.image('https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_12/logo.png')
        st.title("Instructions:")
        st.write("• Select the schema from the available.")
        st.write("• Then select the table which will automatically update to reflect your schema choice.")
        st.write("• Check that the table corresponds to that which you want to ingest into.")
        st.write("• Select the file you want to ingest")
        st.write("• You should see an upload success message detailing how many rows were ingested.")

st.title("Manual CSV File to Snowflake Table Uploader")
selected_schema = st.radio(
    "Select Schema:",
    ["WORLD_BANK_ECONOMIC_INDICATORS",
    "WORLD_BANK_METADATA",
    "WORLD_BANK_SOCIAL_INDIACTORS"])

table_list = get_table_list(selected_schema)

selected_table = st.radio(
    "Select Table to upload to:",
    table_list
    )

st.file_uploader(f"Select file to ingest into {selected_schema}.{selected_table}")

#   Select Table to upload to
#   

#   Status message:
#   Awaiting file to upload
#   Your upload was a success. You uploaded {count} rows.

# Write directly to the app

