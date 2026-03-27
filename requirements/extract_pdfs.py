import sys
import subprocess
import os

try:
    import pypdf
except ImportError:
    print("Installing pypdf...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pypdf"])
    import pypdf

req_dir = r"c:\Users\hp\Documents\moraysolutions\nbrb\bims_mobile_general\requirements"
files = [f for f in os.listdir(req_dir) if f.endswith('.pdf')]
for f in files:
    try:
        print(f"Processing {f}...")
        reader = pypdf.PdfReader(os.path.join(req_dir, f))
        text = ""
        for page in reader.pages:
            t = page.extract_text()
            if t:
                text += t + "\n"
        
        out_path = os.path.join(req_dir, f.replace(".pdf", ".txt"))
        with open(out_path, "w", encoding="utf-8") as out:
            out.write(text)
        print(f"Successfully extracted {out_path}")
    except Exception as e:
        print(f"Failed on {f}: {e}")
