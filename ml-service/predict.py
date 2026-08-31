import os
import joblib
import numpy as np
import xgboost as xgb

MODEL_JSON_PATH = os.path.join(os.path.dirname(__file__), 'model', 'maternal_risk_xgboost.json')
ENCODER_PATH = os.path.join(os.path.dirname(__file__), 'model', 'label_encoder.pkl')

def load_xgboost_model():
    if not os.path.exists(MODEL_JSON_PATH) or not os.path.exists(ENCODER_PATH):
        print(f"[AI Model Error] Model files not found. JSON: {MODEL_JSON_PATH}, PKL: {ENCODER_PATH}")
        return None, None
    try:
        # Load XGBoost classifier
        classifier = xgb.XGBClassifier()
        classifier.load_model(MODEL_JSON_PATH)
        # Load Label Encoder
        label_encoder = joblib.load(ENCODER_PATH)
        return classifier, label_encoder
    except Exception as e:
        print(f"[AI Model Error] Failed to load XGBoost model or Label Encoder: {str(e)}")
        return None, None

def predict_symptom_risk(symptoms_list=None, features=None):
    """
    Predicts the pregnancy risk level.
    Accepts raw features (Age, Temperature, BP, BMI, Glucose) or a symptoms list.
    Loads and runs the local offline XGBoost model.
    """
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
        age = float(features.get('age', age))
        temp = float(features.get('body_temp', temp))
        hr = float(features.get('heart_rate', hr))
        sys = float(features.get('systolic_bp', sys))
        dia = float(features.get('diastolic_bp', dia))
        bmi = float(features.get('bmi', bmi))
        hba1c = float(features.get('hba1c', hba1c))
        fasting_glucose = float(features.get('fasting_glucose', fasting_glucose))
    elif symptoms_list:
        for sym in symptoms_list:
            name = sym.get('name', '').lower()
            val = sym.get('severity', 0)
            if 'infection' in name or 'temp' in name:
                temp = 98.6 + (val / 10.0) * 5.4
            elif 'bp' in name or 'preeclampsia' in name or 'hypertension' in name:
                sys = 120.0 + (val / 10.0) * 50.0
                dia = 80.0 + (val / 10.0) * 30.0
            elif 'glucose' in name or 'sugar' in name or 'diabetes' in name:
                fasting_glucose = 85.0 + (val / 10.0) * 100.0
                hba1c = 5.4 + (val / 10.0) * 3.0
            elif 'tachycardia' in name or 'heart' in name:
                hr = 75.0 + (val / 10.0) * 55.0

    # 1. Try loading the local trained XGBoost model
    classifier, label_encoder = load_xgboost_model()

    if classifier is not None and label_encoder is not None:
        try:
            # Format feature vector exactly in the dataset's order:
            # Age, Body Temperature(F), Heart rate(bpm), Systolic Blood Pressure(mm Hg),
            # Diastolic Blood Pressure(mm Hg), BMI(kg/m 2), Blood Glucose(HbA1c), Blood Glucose(Fasting hour-mg/dl)
            input_vector = [age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose]
            
            # Predict
            prediction_idx = classifier.predict(np.array([input_vector]))[0]
            
            # Extract single value if it is an array
            if hasattr(prediction_idx, '__len__') and not isinstance(prediction_idx, str):
                prediction_idx = prediction_idx[0]
            
            # Inverse transform target label
            prediction_label = label_encoder.inverse_transform([prediction_idx])[0]
            
            # Get prediction probabilities for confidence score
            probabilities = classifier.predict_proba(np.array([input_vector]))[0]
            confidence = float(np.max(probabilities))

            # Map decoded string label (e.g. 'high risk', 'mid risk', 'low risk') to standard app values ('LOW', 'MEDIUM', 'HIGH')
            risk_str = str(prediction_label).lower()
            risk_level = 'LOW'
            if 'high' in risk_str or 'critical' in risk_str:
                risk_level = 'HIGH'
            elif 'mid' in risk_str or 'medium' in risk_str:
                risk_level = 'MEDIUM'
            else:
                risk_level = 'LOW'

            # Log obviously in the backend terminal
            print("\n" + "="*60)
            print("                LOCAL XGBOOST MODEL EVALUATION                ")
            print("="*60)
            print(f"Features: ")
            print(f"  - Age: {age}")
            print(f"  - Body Temp: {temp} °F")
            print(f"  - Heart Rate: {hr} bpm")
            print(f"  - Systolic BP: {sys} mmHg")
            print(f"  - Diastolic BP: {dia} mmHg")
            print(f"  - BMI: {bmi} kg/m²")
            print(f"  - HbA1c: {hba1c} %")
            print(f"  - Fasting Glucose: {fasting_glucose} mg/dL")
            print("-"*60)
            print(f"Output Raw Class Index: {prediction_idx}")
            print(f"Output Decoded Label:    {prediction_label}")
            print(f"Mapped App Risk Level:   {risk_level}")
            print(f"Prediction Confidence:   {confidence:.2%}")
            print("="*60 + "\n")

            reasons = [f"Offline XGBoost AI Model predicted status '{prediction_label}' with {confidence:.1%} confidence."]

            return {
                'success': True,
                'riskLevel': risk_level,
                'confidenceScore': confidence,
                'isRealModel': True,
                'modelLabel': str(prediction_label),
                'recommendations': get_recommendations(risk_level, age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose, reasons)
            }
        except Exception as e:
            print(f"[AI Model Error] Prediction execution failed: {str(e)}. Running rule engine fallback.")

    # 2. Rule-based fallback if model fails or isn't loaded
    print("\n[AI Model Warning] Model fallback triggered.")
    return run_maternal_risk_rules(age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose)


def run_maternal_risk_rules(age, temp, hr, sys, dia, bmi, hba1c, fasting_glucose):
    risk_level = 'LOW'
    reasons = []

    # Blood Pressure / Preeclampsia
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

    # Temperature (Fever/Infection)
    if temp >= 103.0:
        risk_level = 'CRITICAL'
        reasons.append("Very high fever (Temp >= 103°F)")
    elif temp >= 100.4:
        if risk_level != 'CRITICAL':
            risk_level = 'HIGH'
        reasons.append("Fever / Elevated temperature (Temp >= 100.4°F)")

    # Heart Rate
    if hr >= 120 or hr < 50:
        if risk_level != 'CRITICAL':
            risk_level = 'HIGH'
        reasons.append("Abnormal Heart Rate")
    elif hr >= 100 or hr < 60:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append("Mildly abnormal Heart Rate")

    # Blood Glucose (Gestational Diabetes)
    if hba1c >= 6.5 or fasting_glucose >= 126.0:
        if risk_level != 'CRITICAL':
            risk_level = 'HIGH'
        reasons.append("High Blood Glucose in diabetic range")
    elif hba1c >= 5.7 or fasting_glucose >= 95.0:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append("Elevated Blood Glucose in pre-diabetic range")

    # BMI
    if bmi >= 35.0 or bmi < 18.5:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append(f"Abnormal BMI: {bmi:.1f} kg/m²")

    # Age
    if age >= 35 or age < 18:
        if risk_level not in ['CRITICAL', 'HIGH']:
            risk_level = 'MEDIUM'
        reasons.append(f"Age risk factor (Age: {int(age)})")

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
        'isRealModel': False,
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
