import os
import requests
import zipfile
import io
import pandas as pd

api_key = os.getenv("GTFS_API_KEY")  # Use your actual API key
url = f"https://api.resrobot.se/gtfs/sweden.zip?"
params = {"key": api_key}

response = requests.get(url, params=params)
response.raise_for_status()  # Raise error if something failed

# Unzip the downloaded GTFS zip file in memory
with zipfile.ZipFile(io.BytesIO(response.content)) as z:
    # Example: read the agency.txt file into a pandas DataFrame
    with z.open("agency.txt") as f:
        df_agency = pd.read_csv(f)

print(df_agency.to_string())  # Shows operator data (name, URL, ID, etc.)
