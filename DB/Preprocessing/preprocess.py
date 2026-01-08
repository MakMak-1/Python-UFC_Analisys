import pandas as pd
import numpy as np
import requests
from bs4 import BeautifulSoup
from scipy import stats

def fights():
    fights = pd.read_csv("datasets\\large_dataset.csv")
    columns = [0, 1, 2, 3, 4, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]
    fights_preprocessed = fights.iloc[:, columns].copy()

    fights_preprocessed.replace({'total_rounds':np.nan}, 1.0, inplace=True)
    fights_preprocessed['total_rounds'] = fights_preprocessed['total_rounds'].astype('int64')
    fights_preprocessed.to_csv("Fights.csv", sep=";")

def events():
    events = pd.read_csv("datasets\\ufc_event_details.csv")

    def parse_date(date):
        month_dict = {"January":"1","February":"2","March":"3","April":"4","May":"5","June":"6","July":"7","August":"8","September":"9","October":"10","November":"11","December":"12"}
        year = date.split(", ")[1]
        month = month_dict[date.split(", ")[0].split(" ")[0]]
        day = date.split(", ")[0].split(" ")[1]
        date_parsed = f"{year}-{month}-{day}"
        return date_parsed
    
    for i in range(len(events)):
        events.iloc[i, 2] = parse_date(events.iloc[i, 2])
    
    columns = [0, 2, 3]
    events = events.iloc[:, columns].copy()

    urls = ["https://www.tapology.com/search/mma-event-figures/ppv-pay-per-view-buys-buyrate",
       "https://www.tapology.com/search/mma-event-figures/ppv-pay-per-view-buys-buyrate?page=2"]

    headers = {
        "User-Agent": "Mozilla/5.0"
    }

    tables = [None, None]

    for i, url in enumerate(urls):
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.content, "html.parser")
        tables[i] = soup.find("table", class_="siteSearchResults")

    events_scraped = []

    for table in tables:
        rows = table.find_all("tr")[1:]  # Skip the header row
        for row in rows:
            cols = row.find_all("td")
            if len(cols) >= 3:
                event_name = cols[0].get_text(strip=True)
                date = cols[4].get_text(strip=True)
                buys = cols[6].get_text(strip=True)

                if "UFC" in event_name:  # Filter only UFC events
                    events_scraped.append({
                        "event": event_name,
                        "date": date,
                        "ppv_buys": buys
                    })
    
    df_scraped = pd.DataFrame(events)
    df_scraped['ppv_buys'] = df_scraped['ppv_buys'].str.replace(',', '').astype('float64')
    df_scraped['date'] = pd.to_datetime(df_scraped['date'], format='%Y.%m.%d').dt.strftime('%Y-%m-%d').astype(str)

    df_downloaded = pd.read_csv('ppv-buyrates.csv', encoding='cp1252')
    df_downloaded['PPV Buys'] = df_downloaded['PPV Buys'].str.replace(',', '').astype('float64')
    df_downloaded['Date'] = pd.to_datetime(df_downloaded['Date'], format='%m/%d/%Y').dt.strftime('%Y-%m-%d').astype(str)

    events['DATE'] = pd.to_datetime(events['DATE'], format='%Y-%m-%d').dt.strftime('%Y-%m-%d').astype(str)

    events['PPV BUYS'] = np.nan

    for i in range(len(events)):
        date = events.iat[i, 1]
        ppv_scraped = np.nan
        ppv_downloaded = np.nan
        if date in df_scraped.date.values:
            ppv_scraped = df_scraped.loc[df_scraped.date == date].iat[0, 2]
        if date in df_downloaded.Date.values:
            ppv_downloaded = df_downloaded.loc[df_downloaded.Date == date].iat[0, 2]
    
        if ppv_scraped != np.nan:
            events.iat[i, 3] = ppv_scraped
        if ppv_downloaded != np.nan:
            events.iat[i, 3] = ppv_downloaded

    events.to_csv("Events.csv", sep=";")

def fighters():
    fighters = pd.read_csv("datasets\\ufc-fighters-statistics.csv")

    stance_mode = fighters['stance'].mode()[0]
    fighters.replace({'stance':np.nan}, stance_mode, inplace=True)

    avg_weight = fighters['weight_in_kg'].mean().round(2)
    fighters.replace({'weight_in_kg':np.nan}, avg_weight, inplace=True)

    avg_height = fighters['height_cm'].mean().round(2)
    fighters.replace({'height_cm':np.nan}, avg_height, inplace=True)

    fighters_copy = fighters[['height_cm', 'reach_in_cm']]
    fighters_copy = fighters_copy.dropna()

    linreg = stats.linregress(x=fighters_copy['height_cm'], y=fighters_copy['reach_in_cm'])
    m = linreg.slope
    b = linreg.intercept

    for i in range(len(fighters)):
        if pd.isna(fighters.iat[i, 7]):
            fighters.iat[i, 7] = m * fighters.iat[i, 5] + b
    
    fighters.loc[fighters['name'].duplicated(), 'name'] = fighters.loc[fighters['name'].duplicated(), 'name'] + ' 2'
    fighters.to_csv("Fighters.csv", sep=";")

fights()
events()
fighters()