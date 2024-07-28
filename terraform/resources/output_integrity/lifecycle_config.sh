#!/bin/bash

set -e

sudo -u ec2-user -i <<'EOF'
mkdir -p /home/ec2-user/SageMaker/scripts
cd /home/ec2-user/SageMaker/scripts

# Create notebook code
cat <<EOT > train_and_deploy_model.ipynb
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\\n",
    "from sagemaker import get_execution_role\\n",
    "from sagemaker.inputs import TrainingInput\\n",
    "import sagemaker\\n",
    "import json\\n",
    "\\n",
    "# Download dataset\\n",
    "url = 'https://raw.githubusercontent.com/t-davidson/hate-speech-and-offensive-language/master/data/labeled_data.csv'\\n",
    "df = pd.read_csv(url)\\n",
    "\\n",
    "# Select relevant columns and rename them\\n",
    "df = df[['tweet', 'class']]\\n",
    "df.columns = ['comment', 'label']\\n",
    "\\n",
    "# Convert labels to binary (0 = not offensive, 1 = offensive)\\n",
    "df['label'] = df['label'].apply(lambda x: 1 if x == 2 else 0)\\n",
    "\\n",
    "# Prefix labels with '__label__'\\n",
    "df['label'] = df['label'].apply(lambda x: f'__label__{x}')\\n",
    "\\n",
    "# Combine comment and label into a single column\\n",
    "df['text'] = df['label'] + ' ' + df['comment']\\n",
    "\\n",
    "# Save preprocessed data\\n",
    "df['text'].to_csv('offensive_comments.txt', index=False, header=False)\\n",
    "\\n",
    "# Initialize SageMaker session and role\\n",
    "sagemaker_session = sagemaker.Session()\\n",
    "role = get_execution_role()\\n",
    "\\n",
    "# Upload the dataset to S3\\n",
    "s3_bucket = '${s3_bucket_name}'\\n",
    "s3_prefix = 'offensive-language-detection'\\n",
    "s3_train_data = f's3://{s3_bucket}/{s3_prefix}'\\n",
    "\\n",
    "# Upload the data\\n",
    "sagemaker_session.upload_data(path='offensive_comments.txt', bucket=s3_bucket, key_prefix=s3_prefix)\\n",
    "\\n",
    "# Set up the BlazingText estimator\\n",
    "bt = sagemaker.estimator.Estimator(\\n",
    "    image_uri='811284229777.dkr.ecr.us-east-1.amazonaws.com/blazingtext:latest',\\n",
    "    role=role,\\n",
    "    instance_count=1,\\n",
    "    instance_type='ml.m5.large',\\n",
    "    output_path=f's3://{s3_bucket}/{s3_prefix}/output',\\n",
    "    sagemaker_session=sagemaker_session,\\n",
    "    enable_network_isolation=False  # Set this to True if you need network isolation\\n",
    ")\\n",
    "\\n",
    "# Set hyperparameters\\n",
    "bt.set_hyperparameters(mode='supervised', epochs=10, min_count=2, learning_rate=0.05, vector_dim=300)\\n",
    "\\n",
    "# Set up the training input\\n",
    "train_input = TrainingInput(s3_data=s3_train_data, content_type='text/plain')\\n",
    "\\n",
    "# Train the model\\n",
    "bt.fit({'train': train_input})\\n",
    "\\n",
    "# Deploy the model\\n",
    "endpoint_name = 'blazingtext-offensive-comments-endpoint'\\n",
    "bt_predictor = bt.deploy(initial_instance_count=1, instance_type='ml.m5.large', endpoint_name=endpoint_name)\\n",
    "\\n",
    "# Function to make predictions\\n",
    "def is_offensive(comment):\\n",
    "    # Prepare the payload in JSON lines format\\n",
    "    payload = {\"instances\": [comment]}\\n",
    "    \\n",
    "    # Call the endpoint\\n",
    "    response = bt_predictor.predict(\\n",
    "        json.dumps(payload),\\n",
    "        initial_args={'ContentType': 'application/json'}\\n",
    "    )\\n",
    "    \\n",
    "    # Parse the response\\n",
    "    result = json.loads(response)\\n",
    "    print(result)\\n",
    "    prediction = result[0]['label'][0]\\n",
    "    \\n",
    "    return prediction == '__label__1'\\n",
    "\\n",
    "# Example usage\\n",
    "print(is_offensive('You are an idiot!'))  # Should return True\\n",
    "print(is_offensive('Have a nice day!'))  # Should return False\\n"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOT

# Run the notebook to train and deploy the model
nohup jupyter nbconvert --to notebook --execute train_and_deploy_model.ipynb &
EOF