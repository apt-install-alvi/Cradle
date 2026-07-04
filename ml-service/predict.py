import os
import joblib
import numpy as np

MODEL_PATH = os.path.join(os.path.dirname(__file__), 'model', 'risk_model.pkl')

def predict_symptom_risk(symptoms_list):
    """
    Predicts the pregnancy risk level based on the symptoms.
    Uses scikit-learn classifier model if available, otherwise runs heuristic fallback.
    """
    # Fallback to rule engine if model is not trained yet
    if not os.path.exists(MODEL_PATH):
        print("[ML Service Warning] risk_model.pkl not found. Running heuristic model fallback.")
        return run_heuristic_model(symptoms_list)

    try:
        # Load the model
        model_dict = joblib.load(MODEL_PATH)
        classifier = model_dict['classifier']
        symptom_indices = model_dict['symptom_indices']
        
        # Prepare input vector (one-hot or counts)
        input_vector = np.zeros(len(symptom_indices))
        for symptom in symptoms_list:
            name = symptom.get('name', '')
            severity = symptom.get('severity', 0)
            if name in symptom_indices:
                idx = symptom_indices[name]
                input_vector[idx] = severity

        # Predict
        prediction = classifier.predict([input_vector])[0]
        # Get probabilities for confidence score
        probabilities = classifier.predict_proba([input_vector])[0]
        confidence = float(np.max(probabilities))

        # Map predictions to string risk level
        risk_map = {0: 'LOW', 1: 'MEDIUM', 2: 'HIGH', 3: 'CRITICAL'}
        risk_level = risk_map.get(prediction, 'LOW')

        return {
            'success': True,
            'riskLevel': risk_level,
            'confidenceScore': confidence,
            'recommendations': get_recommendations(risk_level)
        }
        
    except Exception as e:
        print(f"[ML Service Error] Failed to load or execute model: {str(e)}. Running heuristic fallback.")
        return run_heuristic_model(symptoms_list)


def run_heuristic_model(symptoms_list):
    max_severity = 0
    for symptom in symptoms_list:
        severity = symptom.get('severity', 0)
        if severity > max_severity:
            max_severity = severity

    if max_severity >= 8:
        risk_level = 'CRITICAL'
        confidence = 0.92
    elif max_severity >= 6:
        risk_level = 'HIGH'
        confidence = 0.88
    elif max_severity >= 4:
        risk_level = 'MEDIUM'
        confidence = 0.85
    else:
        risk_level = 'LOW'
        confidence = 0.95

    return {
        'success': True,
        'riskLevel': risk_level,
        'confidenceScore': confidence,
        'recommendations': get_recommendations(risk_level)
    }


def get_recommendations(risk_level):
    if risk_level == 'CRITICAL':
        return [
            'WARNING: Critical symptoms reported! Please contact your healthcare provider or emergency contacts immediately.',
            'Go to the nearest emergency ward if you experience bleeding or severe abdominal pain.'
        ]
    elif risk_level == 'HIGH':
        return [
            'Schedule a routine check-up with your primary physician as soon as possible.',
            'Rest in a quiet, dark room, and monitor closely for changes in severity.'
        ]
    elif risk_level == 'MEDIUM':
        return [
            'Ensure you are getting enough rest and monitoring your stress levels.',
            'Consult with a physician if this symptom persists for more than 48 hours.'
        ]
    else:
        return [
            'Continue drinking water and tracking your daily symptoms.',
            'Maintain adequate sleep and regular light physical movement.'
        ]
