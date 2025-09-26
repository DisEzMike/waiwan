# WaiWan API Mockup Server

## Installation

1. **Install required packages:**
   ```bash
   pip install fastapi uvicorn
   ```

2. **Verify installation:**
   ```bash
   python --version
   pip list | grep fastapi
   pip list | grep uvicorn
   ```

## Usage

### Starting the Server

1. **Navigate to the project root directory:**
   ```bash
   cd C:\{your_workspace}\waiwan\api_mockup
   ```

2. **Run the FastAPI server:**
   ```bash
   python api_mockup\demo_data_api.py
   ```


### Testing the API

#### Using PowerShell (Windows):
```powershell
# Test elderly persons endpoint
Invoke-RestMethod -Uri "http://192.168.1.130:8000/elderly-persons" -Method Get | ConvertTo-Json -Depth 10

# Test health check
Invoke-RestMethod -Uri "http://192.168.1.130:8000/" -Method Get
```

#### Using curl:
```bash
# Test elderly persons endpoint
curl http://192.168.1.130:8000/elderly-persons

# Test health check
curl http://192.168.1.130:8000/
```


## Set api url in app

visit at [here](../lib/services/api_service.dart)

```dart
  static const String baseUrl = 'http://{change here}:8000';
```

Replace `change here` with your api