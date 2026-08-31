import os
import joblib
import numpy as np

MODEL_PATH = os.path.join(os.path.dirname(__file__), 'model', 'risk_model.pkl')

def predict_symptom_risk(symptoms_list=None, features=None):
    """
    Predicts the pregnancy risk level.
    Accepts raw features (Age, Temperature, BP, BMI, Glucose) or a symptoms list.
    Uses trained classifier if available, otherwise runs heuristic fallback.
    """
    # 1. Parse features to run rule engine or model prediction
    # Defaults (normal healthy values)
    age = 25.0
    temp = 98.6
    hr = 75.0
    sys = 120.0
    dia = 80.0
    bmi = 22.0
    hba1c = 5.4
    fasting_glucose = 85.0

    if features:
        # Extract features from request payload
        age = float(features.get('age', age))
        temp = float(features.get('body_temp', temp))
        hr = float(features.get('heart_rate', hr))
        sys = float(features.get('systolic_bp', sys))
        dia = float(features.get('diastolic_bp', dia))
        bmi = float(features.get('bmi', bmi))
        hba1c = float(features.get('hba1c', hba1c))
        fasting_glucose = float(features.get('fasting_glucose', fasting_glucose))
    elif symptoms_list:
        # Backward compatibility / fallback: Map symptom severities to features
        for sym in symptoms_list:
            name = sym.get('name', '').lower()
            val = sym.get('severity', 0)
            
            # Map simple symptom severities to physiological ranges
            if 'fever' in name or 'temp' in name:
                # Severity 1-10 -> 98.6 to 104.0
                temp = 98.6 + (val / 10.0) * 5.4
            elif 'bp' in name or 'blood pressure' in name or 'hypertension' in name:
                # Severity 1-10 -> 120 to 170 / 80 to 110
                sys = 120.0 + (val / 10.0) * 50.0
                dia = 80.0 + (val / 10.0) * 30.0
            elif 'glucose' in name or 'sugar' in name or 'diabetes' in name:
                # Severity 1-10 -> 85 to 180 fasting
                fasting_glucose = 85.0 + (val / 10.0) * 100.0
                hba1c = 5.4 + (val / 10.0) * 3.0
            elif 'palpitation' in name or 'heart' in name:
                # Severity 1-10 -> 75 to 130
                hr = 75.0 + (val / 10.0) * 55.0
            elif 'breath' in name or 'breathing' in name:
                hr = 75.0 + (val / 10.0) * 30.0
                sys = 120.0 + (val / 10.0) * 20.0

    # Fallback to rule engine if model is not trained yet
    if not os.path.exists(MODEL_PATH):
        print(f"[ML Service Warning] risk_model.pkl not found at {MODEL_PATH}. Running heuristic model fallback.")
        return run_maternal_risk_rules(age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose)

    try:
        # Load the model (e.g. XGBoost or Random Forest)
        model_dict = joblib.load(MODEL_PATH)
        classifier = model_dict['classifier']
        
        # Format feature vector exactly in the dataset's order:
        # Age, Body Temperature(F), Heart rate(bpm), Systolic Blood Pressure(mm Hg),
        # Diastolic Blood Pressure(mm Hg), BMI(kg/m 2), Blood Glucose(HbA1c), Blood Glucose(Fasting hour-mg/dl)
        input_vector = [age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose]
        
        # Predict
        prediction = classifier.predict([input_vector])[0]
        probabilities = classifier.predict_proba([input_vector])[0]
        confidence = float(np.max(probabilities))

        # Map predictions (numeric classes to labels)
        # Note: If target is string 'high risk', etc. check what predictions are returned
        # Usually it maps classes alphabetically or numerically. We handle integer index or string.
        risk_level = 'LOW'
        if isinstance(prediction, (int, np.integer)):
            risk_map = {0: 'LOW', 1: 'MEDIUM', 2: 'HIGH', 3: 'CRITICAL'}
            risk_level = risk_map.get(prediction, 'LOW')
        else:
            pred_str = str(prediction).lower()
            if 'high' in pred_str or 'critical' in pred_str:
                risk_level = 'HIGH'
            elif 'medium' in pred_str or 'mid' in pred_str:
                risk_level = 'MEDIUM'
            else:
                risk_level = 'LOW'

        return {
            'success': True,
            'riskLevel': risk_level,
            'confidenceScore': confidence,
            'recommendations': get_recommendations(risk_level, age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose)
        }
        
    except Exception as e:
        print(f"[ML Service Error] Failed to load or execute model: {str(e)}. Running heuristic fallback.")
        return run_maternal_risk_rules(age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose)


def run_maternal_risk_rules(age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose):
    """
    A detailed physiological rule engine that computes pregnancy risk status
    using the 8 dataset features.
    """
    risk_level = 'LOW'
    reasons = []

    # 1. Blood Pressure / Preeclampsia
    if sys >= 160 or dia >= 110:
        risk_level = 'CRITICAL'
        reasons.append("Severe hypertension (BP >= 160/110 mmHg)")
    elif sys >= 140 or dia >= 90:
        if risk_level != 'CRITICAL':
            risk_level = 'HIGH'
        reasons.append("High Blood Pressure (BP >= 140/90 mmHg)")
    elif sys >= 130 or dia >= 85:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append("Elevated Blood Pressure (BP >= 130/85 mmHg)")

    # 2. Temperature (Fever/Infection)
    if temp >= 103.0:
        risk_level = 'CRITICAL'
        reasons.append("Very high fever (Temp >= 103°F)")
    elif temp >= 100.4:
        if risk_level != 'CRITICAL':
            risk_level = 'HIGH'
        reasons.append("Fever / Elevated temperature (Temp >= 100.4°F)")

    # 3. Heart Rate
    if hr >= 120 or hr < 50:
        if risk_level != 'CRITICAL':
            risk_level = 'HIGH'
        reasons.append("Abnormal Heart Rate (Heart rate is either tachycardia or bradycardia)")
    elif hr >= 100 or hr < 60:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append("Mildly abnormal Heart Rate")

    # 4. Blood Glucose (Gestational Diabetes)
    if hba1c >= 6.5 or fasting_glucose >= 126.0:
        if risk_level != 'CRITICAL':
            risk_level = 'HIGH'
        reasons.append("High Blood Glucose in diabetic range")
    elif hba1c >= 5.7 or fasting_glucose >= 95.0:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append("Elevated Blood Glucose in pre-diabetic range")

    # 5. BMI (high/low pregnancy risk factors)
    if bmi >= 35.0 or bmi < 18.5:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append(f"Abnormal BMI: {bmi:.1f} kg/m²")

    # 6. Age
    if age >= 35 or age < 18:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append(f"Age risk factor (Age: {int(age)})")

    # Determine confidence score
    confidence = 0.95
    if risk_level == 'CRITICAL':
        confidence = 0.94
    elif risk_level == 'HIGH':
        confidence = 0.89
    elif risk_level == 'MEDIUM':
        confidence = 0.84

    return {
        'success': True,
        'riskLevel': risk_level,
        'confidenceScore': confidence,
        'recommendations': get_recommendations(risk_level, age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose, reasons)
    }


def get_recommendations(risk_level, age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose, reasons=None):
    reasons_str = f" Factors: {', '.join(reasons)}." if reasons else ""
    if risk_level == 'CRITICAL':
        return [
            f"URGENT ASSISTANCE REQUIRED!{reasons_str}",
            "Please go to the nearest emergency ward or call emergency services immediately.",
            "Inform your gynaecologist of these vital levels right away.",
        ]
    elif risk_level == 'HIGH':
        return [
            f"High Pregnancy Risk detected.{reasons_str}",
            "Schedule an urgent consultation with your obstetrician / primary physician.",
            "Rest completely, monitor blood pressure, and keep logs of these vitals.",
        ]
    elif risk_level == 'MEDIUM':
        return [
            f"Moderate Risk level.{reasons_str}",
            "Notify your healthcare provider of these readings at your next check-up.",
            "Maintain balanced meals, limit sodium intake, and stay hydrated.",
        ]
    else:
        return [
            "Low risk level. Your pregnancy health metrics look stable.",
            "Continue regular checkups, light exercises, and tracking your vitals daily.",
        ]
