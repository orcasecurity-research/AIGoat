import json
import boto3
import logging
import traceback

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize SageMaker runtime client
runtime = boto3.client('sagemaker-runtime')


def lambda_handler(event, context):
    try:
        logger.info(f"Event: {event}")

        # Extract comment from the event
        body = json.loads(event['body'])
        comment = body['content']
        author = body.get('author')
        is_offensive = body.get('is_offensive')
        probability = body.get('probability')
        logger.info(f"Comment: {comment}")

        # Prepare the payload for the SageMaker endpoint
        payload = {"instances": [comment]}

        # Convert payload to JSON string
        payload_str = json.dumps(payload)
        logger.info(f"Payload JSON String: {payload_str}")

        # Call the SageMaker endpoint
        response = runtime.invoke_endpoint(
            EndpointName='blazingtext-offensive-comments-endpoint',  # Replace with your endpoint name
            ContentType='application/json',
            Body=payload_str
        )

        # Log the response for debugging
        logger.info(f"Response: {response}")

        # Parse the response
        result = json.loads(response['Body'].read().decode())
        logger.info(f"Parsed result: {result}")

        # Check the structure of the result and extract the prediction
        prediction = result[0]
        logger.info(f"Prediction: {prediction}")


        if not is_offensive or not probability:
            if isinstance(prediction, dict) and 'label' in prediction:
                label = prediction['label']
                is_offensive = [1 if (label == '__label__1' if isinstance(label, str) else label[0] == '__label__1') else 0]
                probability = prediction.get('prob', [])
            else:
                is_offensive = [1 if prediction == '__label__1' else 0]
                probability = prediction.get('prob', [])

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'author': str(author), 'comment': str(comment), 'is_offensive': is_offensive, 'probability': probability})
        }
    except KeyError as e:
        logger.error(f"KeyError: {e}")
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': f'Missing key: {str(e)}'})
        }
    except Exception as e:
        logger.error(f"Exception: {e}")
        logger.error(f"Traceback: {traceback.format_exc()}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }