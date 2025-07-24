from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import pickle
import numpy as np

# Load artifacts
with open('best_model.pkl', 'rb') as f:
    model = pickle.load(f)
with open('scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)
with open('label_encoders.pkl', 'rb') as f:
    label_encoders = pickle.load(f)

# Define mappings for categorical variables
REGION_MAPPING = {
    "West": 0,
    "East": 1,
    "North": 2,
    "South": 3
}

SOIL_TYPE_MAPPING = {
    "Sandy": 0,
    "Clay": 1,
    "Loamy": 2,
    "Black": 3,
    "Red": 4,
    "Silt": 5
}

CROP_MAPPING = {
    "Cotton": 0,
    "Maize": 1,
    "Rice": 2,
    "Wheat": 3,
    "Soybean": 4,
    "Sugarcane": 5
}

WEATHER_CONDITION_MAPPING = {
    "Sunny": 0,
    "Cloudy": 1,
    "Rainy": 2
}

# FastAPI app
app = FastAPI(
    title="Crop Yield Prediction API",
    description="Predict crop yields using a linear regression model for your summative assignment.",
    version="1.0",
)

# CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic model for input validation
class PredictionInput(BaseModel):
    Region: str = Field(..., description="Region (West, East, North, South)")
    Soil_Type: str = Field(..., description="Soil type (Sandy, Clay, Loamy, Black, Red, Silt)")
    Crop: str = Field(..., description="Crop type (Cotton, Maize, Rice, Wheat, Soybean, Sugarcane)")
    Rainfall_mm: float = Field(..., ge=0, le=1000)
    Temperature_Celsius: float = Field(..., ge=-10, le=50)
    Fertilizer_Used: bool
    Irrigation_Used: bool
    Weather_Condition: str = Field(..., description="Weather condition (Sunny, Cloudy, Rainy)")
    Days_to_Harvest: int = Field(..., ge=10, le=400)

    class Config:
        schema_extra = {
            "example": {
                "Region": "West",
                "Soil_Type": "Sandy",
                "Crop": "Cotton",
                "Rainfall_mm": 500,
                "Temperature_Celsius": 25,
                "Fertilizer_Used": True,
                "Irrigation_Used": False,
                "Weather_Condition": "Sunny",
                "Days_to_Harvest": 90
            }
        }

@app.post("/predict")
async def predict_yield(data: PredictionInput):
    try:
        # Convert to dict for processing
        input_data = data.dict()

        # Convert categorical strings to integers using mappings
        try:
            input_data['Region'] = REGION_MAPPING[input_data['Region']]
            input_data['Soil_Type'] = SOIL_TYPE_MAPPING[input_data['Soil_Type']]
            input_data['Crop'] = CROP_MAPPING[input_data['Crop']]
            input_data['Weather_Condition'] = WEATHER_CONDITION_MAPPING[input_data['Weather_Condition']]
        except KeyError as e:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid value for {str(e)}. Please check the documentation for valid values."
            )

        # Convert booleans to int
        input_data['Fertilizer_Used'] = int(input_data['Fertilizer_Used'])
        input_data['Irrigation_Used'] = int(input_data['Irrigation_Used'])

        # Create ordered feature array
        feature_order = [
            'Region', 'Soil_Type', 'Crop', 'Rainfall_mm', 'Temperature_Celsius',
            'Fertilizer_Used', 'Irrigation_Used', 'Weather_Condition', 'Days_to_Harvest'
        ]
        input_array = np.array([input_data[feat] for feat in feature_order]).reshape(1, -1)

        # Scale features
        input_scaled = scaler.transform(input_array)

        # Predict
        prediction = model.predict(input_scaled)[0]

        return {"predicted_yield_ton_per_ha": prediction}

    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        return {"error": str(e)}