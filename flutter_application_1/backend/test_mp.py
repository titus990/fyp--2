import mediapipe as mp
import importlib
import sys
import traceback

with open("mp_test_result.txt", "w") as f:
    try:
        f.write(f"MP dir: {dir(mp)}\n")
        f.write(f"MP solutions: {getattr(mp, 'solutions', 'MISSING')}\n")
    except Exception:
        f.write(f"Error accessing solutions:\n{traceback.format_exc()}\n")

    try:
        solutions = importlib.import_module("mediapipe.python.solutions")
        f.write(f"Imported solutions via importlib: {solutions}\n")
    except ImportError:
        f.write(f"ImportError via importlib:\n{traceback.format_exc()}\n")
    except Exception:
        f.write(f"Other error via importlib:\n{traceback.format_exc()}\n")
