import os
import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier

# Define symptoms list matching Flutter symptom list entries
symptoms = [
    'Headache',
    'Nausea / Vomiting',
    'Swelling (Hands/Face)',
    'Fever',
    'Abdominal Pain',
    'Fatigue',
    'Vision Changes (Blurriness)'
]

symptom_indices = {s: i for i, s in enumerate(symptoms)}

# Generate dummy training dataset
# X: severity levels (0 to 10 scale)
# y: risk class index (0: LOW, 1: MEDIUM, 2: HIGH, 3: CRITICAL)
X = []
y = []

# Generate 200 samples
np.random.seed(42)
for _ in range(200):
    sample = np.random.randint(0, 11, size=len(symptoms))
    max_sev = np.max(sample)
    
    # Simple rule-based label generation for training simulation
    if sample[4] >= 8 or sample[3] >= 8: # Abdominal Pain/Fever is critical
        risk = 3 # CRITICAL
    elif max_sev >= 7:
        risk = 2 # HIGH
    elif max_sev >= 4:
        risk = 1 # MEDIUM
    else:
        risk = 0 # LOW
        
    X.append(sample)
    y.append(risk)

X = np.array(X)
y = np.array(y)

# Fit RandomForest Classifier
clf = RandomForestClassifier(n_estimators=10, random_state=42)
clf.fit(X, y)

# Save serialized binary file
os.makedirs(os.path.join(os.path.dirname(__file__), 'model'), exist_ok=True)
model_file = os.path.join(os.path.dirname(__file__), 'model', 'risk_model.pkl')

joblib.dump({
    'classifier': clf,
    'symptom_indices': symptom_indices
}, model_file)

print(f"Dummy Random Forest classifier model compiled successfully at: {model_file}")
