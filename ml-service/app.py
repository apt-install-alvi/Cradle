from flask import Flask, request, jsonify
from predict import predict_symptom_risk

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'cradle-ml-service'
    })

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    if not data or 'symptoms' not in data:
        return jsonify({
            'success': False,
            'message': 'No symptoms list provided in request body.'
        }), 400
        
    symptoms = data['symptoms']
    result = predict_symptom_risk(symptoms)
    return jsonify(result)

if __name__ == '__main__':
    # Listen on port 5001 (as specified in Express dotenv configurations)
    app.run(host='0.0.0.0', port=5001, debug=False)
