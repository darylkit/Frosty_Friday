# Copyright (c) Streamlit Inc. (2018-2022) Snowflake Inc. (2022)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import streamlit as st
from streamlit.logger import get_logger
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
import pandas as pd

ctx = snowflake.connector.connect(
    user=st.secrets["user"],
    password=st.secrets["password"],
    account=st.secrets["account"],
    database="FROSTY_FRIDAY"
    )
cs = ctx.cursor()

LOGGER = get_logger(__name__)

def run():
    def get_table_list(selected_schema):
      if selected_schema == "WORLD_BANK_ECONOMIC_INDICATORS":
        return ["GDP","GOV_EXPENDITURE"]
      elif selected_schema == "WORLD_BANK_METADATA":
        return ["COUNTRY_METADATA"]
      elif selected_schema == "WORLD_BANK_SOCIAL_INDIACTORS":
        return ["LIFE_EXPECTANCY","ADULT_LITERACY_RATE","PROGRESSION_TO_SECONDARY_SCHOOL"]
      else:
        return []

    with st.sidebar:
            st.image('https://frostyfridaychallenges.s3.eu-west-1.amazonaws.com/challenge_12/logo.png')
            st.title("Instructions:")
            st.write("- Select the schema from the available.")
            st.write("- Then select the table which will automatically update to reflect your schema choice.")
            st.write("- Check that the table corresponds to that which you want to ingest into.")
            st.write("- Select the file you want to ingest")
            st.write("- You should see an upload success message detailing how many rows were ingested.")

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

    uploaded_file  = st.file_uploader(f"Select file to ingest into {selected_schema}.{selected_table}")
    if uploaded_file is not None:
      dataframe = pd.read_csv(uploaded_file)
      cs.execute(f"USE SCHEMA {selected_schema}")
      dataframe.columns = dataframe.columns.str.upper()
      success, nchunks, nrows, _ = write_pandas(ctx, dataframe, f"{selected_table}")
      st.markdown(f"Your upload was a success. You uploaded {nrows} rows.")
    else:
      st.markdown("Awaiting file to upload")

if __name__ == "__main__":
    run()
