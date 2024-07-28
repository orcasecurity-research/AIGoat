import json
import boto3
import numpy as np
from PIL import Image
import io
import base64
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize SageMaker runtime client
sagemaker_runtime = boto3.client('sagemaker-runtime')
s3_client = boto3.client('s3')

# SageMaker endpoint name
ENDPOINT_NAME = 'image-similarity-endpoint'


def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes))
    image = image.resize((224, 224))  # Resize the image to the required input size
    image_array = np.array(image)

    if image_array.shape[-1] == 1:  # Grayscale to RGB conversion
        image_array = np.repeat(image_array[..., np.newaxis], 3, -1)

    image_array = np.expand_dims(image_array, axis=0)  # Add batch dimension

    # Convert RGB to BGR
    image_array = image_array[..., ::-1]

    # Zero-center by mean pixel values from the ImageNet dataset
    mean = [103.939, 116.779, 123.68]
    image_array = image_array.astype(np.float32)
    image_array[..., 0] -= mean[0]
    image_array[..., 1] -= mean[1]
    image_array[..., 2] -= mean[2]

    return image_array.tolist()


def lambda_handler(event, context):
    logger.info(f"Event: {event}")
    try:
        # Extract bucket name and image key from the event
        if 'body' in event:
            # Parse the body of the request
            body = json.loads(event['body'])
            bucket_name = body.get('bucket_name')
            img_key = body.get('img_key')
        else:
            # Fallback to direct invocation format
            bucket_name = event.get('bucket_name')
            img_key = event.get('img_key')

        # Retrieve the image from S3
        response = s3_client.get_object(Bucket=bucket_name, Key=img_key)
        image_bytes = response['Body'].read()

        # Preprocess the image
        preprocessed_image = preprocess_image(image_bytes)

        input_data = json.dumps({'instances': preprocessed_image})

        # Invoke the SageMaker endpoint
        response = sagemaker_runtime.invoke_endpoint(
            EndpointName=ENDPOINT_NAME,
            ContentType='application/json',
            Body=input_data
        )

        # Parse the response from SageMaker
        response_body = response['Body'].read().decode('utf-8')
        similar_images = json.loads(response_body)

        # Return the response
        return {
            'statusCode': 200,
            'body': json.dumps(similar_images)
        }
    except Exception as e:
        logger.error(f"Exception: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }