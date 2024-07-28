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
    "!pip install tensorflow\\n",
    "import boto3\\n",
    "import numpy as np\\n",
    "from PIL import Image\\n",
    "from io import BytesIO\\n",
    "import tensorflow as tf\\n",
    "from tensorflow.keras.applications.resnet50 import ResNet50, preprocess_input\\n",
    "from tensorflow.keras.models import Model\\n",
    "from sklearn.metrics.pairwise import cosine_similarity\\n",
    "import pickle\\n",
    "import json\\n",
    "import tarfile\\n",
    "import sagemaker\\n",
    "from sagemaker import get_execution_role\\n",
    "from sagemaker.tensorflow import TensorFlowModel\\n",
    "\\n",
    "# Initialize S3 client\\n",
    "s3 = boto3.client('s3')\\n",
    "bucket_name = '${s3_bucket_name}'\\n",
    "\\n",
    "# Load the pre-trained ResNet50 model\\n",
    "base_model = ResNet50(weights='imagenet', include_top=False, pooling='avg')\\n",
    "model = Model(inputs=base_model.input, outputs=base_model.output)\\n",
    "\\n",
    "# Save the model using the SavedModel format\\n",
    "model.export('model/1')\\n",
    "\\n",
    "with tarfile.open('model.tar.gz', mode='w:gz') as archive:\\n",
    "    archive.add('model/1', recursive=True)\\n",
    "\\n",
    "s3.upload_file('model.tar.gz', bucket_name, 'model/model.tar.gz')\\n",
    "\\n",
    "# Step 1: Download and preprocess images, then extract features\\n",
    "def preprocess_image(image_data):\\n",
    "    img = Image.open(BytesIO(image_data))\\n",
    "    img = img.resize((224, 224))\\n",
    "    img_array = np.array(img)\\n",
    "    img_array = np.expand_dims(img_array, axis=0)\\n",
    "    img_array = preprocess_input(img_array)\\n",
    "    return img_array\\n",
    "\\n",
    "def extract_features(img_data):\\n",
    "    img_array = preprocess_image(img_data)\\n",
    "    resnet_features = model.predict(img_array)\\n",
    "    return resnet_features\\n",
    "\\n",
    "# List all images in the S3 bucket\\n",
    "prefix = 'product-pictures/'\\n",
    "response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)\\n",
    "all_images = [item['Key'] for item in response.get('Contents', []) if item['Key'].endswith(('jpg', 'png'))]\\n",
    "\\n",
    "# Extract features for all images and store them\\n",
    "features = {}\\n",
    "for img_key in all_images:\\n",
    "    response = s3.get_object(Bucket=bucket_name, Key=img_key)\\n",
    "    img_data = response['Body'].read()\\n",
    "    features[img_key] = extract_features(img_data)\\n",
    "\\n",
    "# Save features to a file\\n",
    "with open('image_features.pkl', 'wb') as f:\\n",
    "    pickle.dump(features, f)\\n",
    "\\n",
    "s3.upload_file('image_features.pkl', bucket_name, 'image_features.pkl')\\n",
    "\\n",
    "# Load precomputed features\\n",
    "with open('image_features.pkl', 'rb') as f:\\n",
    "    features = pickle.load(f)\\n",
    "\\n",
    "# Initialize SageMaker session and role\\n",
    "sagemaker_session = sagemaker.Session()\\n",
    "role = get_execution_role()\\n",
    "\\n",
    "# Create SageMaker model\\n",
    "model_data_url = f's3://{bucket_name}/model/model.tar.gz'\\n",
    "sagemaker_model = TensorFlowModel(\\n",
    "    model_data=model_data_url,\\n",
    "    role=role,\\n",
    "    framework_version='2.8'\\n",
    ")\\n",
    "\\n",
    "# Deploy the model with a custom endpoint name\\n",
    "custom_endpoint_name = 'image-similarity-endpoint'\\n",
    "predictor = sagemaker_model.deploy(initial_instance_count=1, instance_type='ml.m4.xlarge', endpoint_name=custom_endpoint_name)\\n",
    "\\n",
    "# Function to find similar images\\n",
    "def find_similar_images(query_features, top_n=5):\\n",
    "    similarities = {}\\n",
    "    \\n",
    "    for img_key, img_features in features.items():\\n",
    "        similarity = cosine_similarity([query_features], img_features)[0][0]\\n",
    "        similarities[img_key] = similarity\\n",
    "    \\n",
    "    sorted_images = sorted(similarities.items(), key=lambda x: x[1], reverse=True)\\n",
    "    return sorted_images[:top_n]\\n"
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
