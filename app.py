from google.cloud import bigquery
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report
import joblib


# Connect to BigQuery and Explore the Data

client = bigquery.Client(project="ensai-2026")
query = "SELECT * FROM `ensai-2026.ml.prenoms`"
df = client.query(query).to_dataframe()
df.columns = ["sexe", "nom", "annee", "nombre"]


# Feature Engineering

df["last_letter"] = df["nom"].str[-1].str.lower()

df = df.dropna()

y = df["sexe"]
X = df["nom"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)


# Train and Evaluate the Model

model = Pipeline(
    [
        (
            "vectorizer",
            CountVectorizer(analyzer="char", ngram_range=(2, 3)),
        ),
        ("classifier", LogisticRegression(random_state=0, max_iter=1000)),
    ]
)

pipeline = model.fit(X_train, y_train)
print(classification_report(y_test, pipeline.predict(X_test)))
joblib.dump(pipeline, "name_gender_identification/model.joblib")
