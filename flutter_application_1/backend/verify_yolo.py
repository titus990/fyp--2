
try:
    from ultralytics import YOLO
    print("Ultralytics imported successfully.")
    
    # Try initializing the model (this might trigger download)
    model = YOLO('yolov8n-pose.pt')
    print("Model initialized successfully.")
except ImportError as e:
    print(f"ImportError: {e}")
except Exception as e:
    print(f"Error: {e}")
