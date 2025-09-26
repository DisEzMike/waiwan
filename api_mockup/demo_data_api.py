from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import json
import os

app = FastAPI(title="WaiWan Demo API", description="API for elderly care service demo data")

# Pydantic models
class ChatMessage(BaseModel):
    message: str
    is_me: bool
    timestamp: datetime
    sender_name: str

class Review(BaseModel):
    review_id: str
    reviewer_name: str
    reviewer_avatar: str = ""
    rating: int
    comment: str
    review_date: datetime

class ElderlyPerson(BaseModel):
    name: str
    distance: str
    ability: str
    image_url: str
    phone_number: int
    chronic_diseases: str
    work_experience: str
    address: str
    reviews: List[Review] = []
    is_verified: bool = False

# Function to load data from JSON file
def load_demo_data():
    """Load demo data from JSON file"""
    json_file_path = os.path.join(os.path.dirname(__file__), 'demo_data.json')
    
    try:
        with open(json_file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
        
        # Convert JSON data to Pydantic models
        chat_messages = []
        for msg in data.get('chat_messages', []):
            msg['timestamp'] = datetime.fromisoformat(msg['timestamp'])
            chat_messages.append(ChatMessage(**msg))
        
        elderly_persons = []
        for person_data in data.get('elderly_persons', []):
            # Convert reviews
            reviews = []
            for review_data in person_data.get('reviews', []):
                review_data['review_date'] = datetime.fromisoformat(review_data['review_date'])
                reviews.append(Review(**review_data))
            
            person_data['reviews'] = reviews
            elderly_persons.append(ElderlyPerson(**person_data))
        
        return chat_messages, elderly_persons
    
    except FileNotFoundError:
        print("Warning: demo_data.json not found. Using empty data.")
        return [], []
    except Exception as e:
        print(f"Error loading demo data: {e}")
        return [], []

# Load demo data
demo_chat_messages, demo_elderly_persons = load_demo_data()

# API Endpoints
@app.get("/")
async def root():
    return {"message": "WaiWan Demo API - Elderly Care Service"}

@app.get("/chat-messages", response_model=List[ChatMessage])
async def get_chat_messages():
    """Get demo chat messages"""
    return demo_chat_messages

@app.get("/elderly-persons", response_model=List[ElderlyPerson])
async def get_elderly_persons():
    """Get list of elderly persons available for services"""
    return demo_elderly_persons

@app.get("/elderly-persons/{person_name}", response_model=ElderlyPerson)
async def get_elderly_person_by_name(person_name: str):
    """Get specific elderly person by name"""
    for person in demo_elderly_persons:
        if person.name == person_name:
            return person
    return {"error": "Person not found"}

@app.get("/reviews", response_model=List[Review])
async def get_all_reviews():
    """Get all reviews from all elderly persons"""
    all_reviews = []
    for person in demo_elderly_persons:
        all_reviews.extend(person.reviews)
    return all_reviews

@app.get("/reviews/{review_id}", response_model=Review)
async def get_review_by_id(review_id: str):
    """Get specific review by ID"""
    for person in demo_elderly_persons:
        for review in person.reviews:
            if review.review_id == review_id:
                return review
    return {"error": "Review not found"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)