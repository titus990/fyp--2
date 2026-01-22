import cv2
import numpy as np
try:
    from ultralytics import YOLO
except ImportError:
    YOLO = None

class PunchAnalyzer:
    def __init__(self):
        if YOLO is None:
             raise RuntimeError("Ultralytics library is not installed. Please run 'pip install ultralytics'.")
        
        # Load the YOLOv8 Pose model (nano version for speed)
        # This will download 'yolov8n-pose.pt' on first use
        self.model = YOLO('yolov8n-pose.pt')

    def calculate_angle(self, a, b, c):
        a = np.array(a)  # First
        b = np.array(b)  # Mid
        c = np.array(c)  # End

        radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
        angle = np.abs(radians * 180.0 / np.pi)

        if angle > 180.0:
            angle = 360 - angle

        return angle

    def analyze_video(self, video_path):
        cap = cv2.VideoCapture(video_path)
        frames_analysis = []
        
        frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        if fps == 0: fps = 30 # Default if unknown

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            # Convert to RGB
            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            image.flags.writeable = False

            # Process with YOLOv8
            results = self.model(image, verbose=False)

            frame_data = {
                'timestamp': cap.get(cv2.CAP_PROP_POS_MSEC),
                'pose_found': False,
                'feedback': []
            }

            # Check if any pose is detected
            # results[0].keypoints.xyn gives normalized coordinates (0-1)
            # Shape is (N, 17, 2) where N is number of persons
            if results and results[0].keypoints is not None and len(results[0].keypoints.xyn) > 0:
                # Assuming single person - take the first one
                keypoints = results[0].keypoints.xyn[0]
                
                # Check confidence or valid data (if all 0, it's invalid)
                if keypoints.shape[0] >= 11: # Ensure we have enough keypoints
                    frame_data['pose_found'] = True
                    
                    # YOLOv8 Pose Keypoints (COCO):
                    # 5: Left Shoulder, 6: Right Shoulder
                    # 7: Left Elbow, 8: Right Elbow
                    # 9: Left Wrist, 10: Right Wrist
                    
                    # Extract coordinates (normalized)
                    # Note: Tensor values, need to convert to native (float) if they are tensors
                    # ultralytics returns tensors usually. .tolist() or item() works.
                    kpts = keypoints.cpu().numpy() # Convert to numpy array

                    # Left side
                    l_shoulder = kpts[5]
                    l_elbow = kpts[7]
                    l_wrist = kpts[9]
                    
                    # Right side
                    r_shoulder = kpts[6]
                    r_elbow = kpts[8]
                    r_wrist = kpts[10]
                    
                    # Only proceed if confidence is likely good (non-zero mostly)
                    # YOLO often outputs 0,0 for undetected points.
                    if np.any(l_shoulder) and np.any(l_elbow) and np.any(l_wrist) and \
                       np.any(r_shoulder) and np.any(r_elbow) and np.any(r_wrist):
                        
                        # Calculate angles
                        l_angle = self.calculate_angle(l_shoulder, l_elbow, l_wrist)
                        r_angle = self.calculate_angle(r_shoulder, r_elbow, r_wrist)

                        frame_data['left_arm_angle'] = l_angle
                        frame_data['right_arm_angle'] = r_angle
                        
                        # Store landmarks for velocity calc (converting to object-like structure or dict)
                        # The existing velocity logic expects landmarks[index].x / .y
                        
                        # Mapping YOLO (10) to MP (16) for Right Wrist
                        # Let's just store the specific ones we need in a clean generic format
                        frame_data['right_wrist'] = Landmark(r_wrist[0], r_wrist[1])
                        
                        # For compatibility with `generate_summary`:
                        # It uses frame_data['landmarks']
                        # Let's just rewrite generate_summary logic slightly or mock the data structure.
                        # Simpler: Update `generate_summary` to use `frame_data['right_wrist']`
                        
                        frames_analysis.append(frame_data)
            
        cap.release()
        
        if not frames_analysis:
             return {
                "score": 0,
                "feedback": ["No pose detected in video. Ensure you are fully visible."],
                "metrics": {}
            }

        return self.generate_summary(frames_analysis, fps)

class Landmark:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def generate_summary(self, frames, fps):
        # Heuristic Analysis
        # 1. Detect extension (Punch) -> Angle nearing 180 degrees
        # 2. Estimate Speed -> Change in wrist position over time
        
        max_left_ext = 0
        max_right_ext = 0
        max_velocity = 0
        
        punch_detected = False
        punch_type = "Unknown"
        
        # Simple velocity calc (distance moved per frame)
        for i in range(1, len(frames)):
            prev = frames[i-1]
            curr = frames[i]
            
            if not prev['pose_found'] or not curr['pose_found']:
                continue
                
            l_angle = curr['left_arm_angle']
            r_angle = curr['right_arm_angle']
            
            max_left_ext = max(max_left_ext, l_angle)
            max_right_ext = max(max_right_ext, r_angle)
            
            # Estimate wrist velocity (rudimentary)
            # We use just raw coordinate distance for now, normalized by FPS
            # Proper would be to project to world coordinates if depth known
            # Estimate wrist velocity (rudimentary)
            # We use just raw coordinate distance for now, normalized by FPS
            curr_rw = curr.get('right_wrist')
            prev_rw = prev.get('right_wrist')
            
            if curr_rw is None or prev_rw is None:
                continue
            
            dist = np.sqrt((curr_rw.x - prev_rw.x)**2 + (curr_rw.y - prev_rw.y)**2)
            velocity = dist * fps # Units / sec
            max_velocity = max(max_velocity, velocity)
        
        score = 0
        feedback = []
        
        # Determine if a punch happened (Extension > 150 deg)
        if max_right_ext > 160 or max_left_ext > 160:
            punch_detected = True
            score += 50 # Base score for extending
            
            if max_velocity > 2.0: # Arbitrary threshold needs tuning
                score += 30
                feedback.append("Good speed!")
            elif max_velocity > 1.0:
                 score += 15
                 feedback.append("Average speed. Try to snap your punch.")
            else:
                 feedback.append("Too slow. Explosive power needed.")
                 
            if max_left_ext > 170 or max_right_ext > 170:
                score += 20
                feedback.append("Excellent extension!")
            elif max_left_ext < 140 and max_right_ext < 140:
                feedback.append("Incomplete extension. Fully extend your arm.")
                
        else:
            feedback.append("No full punch detected. Make sure to extend your arm.")
            score = 10

        return {
            "score": min(score, 100),
            "feedback": feedback,
            "metrics": {
                "max_velocity": round(max_velocity, 2),
                "max_extension": round(max(max_left_ext, max_right_ext), 2)
            }
        }
