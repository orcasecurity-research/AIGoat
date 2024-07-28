import boto3
import json


def lambda_handler(event, context):
    # Get the user_id from the event body
    if isinstance(event, dict) and 'user_id' in event:
        user_id = event['user_id']
    else:
        # If not, try to parse the body
        body = json.loads(event.get('body', '{}'))
        user_id = body.get('user_id')

    # Initialize a boto3 client for SageMaker Runtime
    runtime = boto3.client('sagemaker-runtime')

    # Prepare the input payload: converting user_id to string as the endpoint expects a string input
    payload = str(user_id)

    # Define your SageMaker endpoint name
    endpoint_name = 'reccomendation-system-endpoint'

    # Invoke the SageMaker endpoint
    response = runtime.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType='text/plain',  # Ensure this matches the content type expected by your input_fn
        Body=payload
    )

    # Decode the response
    result = response['Body'].read().decode('utf-8')

    # Return the result as a JSON response
    return {
        'statusCode': 200,
        'body': json.dumps({
            'recommended_items': result
        })
    }
