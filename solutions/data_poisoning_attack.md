# Objectives

Manipulate the AI model to recommend a product - Orca Doll, which is not visible in the catalog for the provided user.

# Solutions

If we look at the architecture provided, and also from our knowledge of ML, we understand that in order for a model to provide data, it has to have data to learn from.

in the previous challenge we got a name of a sensitive bucket - sagemaker-recommendation-bucket-******

running the following command will show us the contents of the bucket:

```
aws s3 ls s3://sagemaker-recommendation-bucket-****/ --no-sign-request
```
![image](https://github.com/user-attachments/assets/9d185d82-98da-4a68-b6a2-7f190e42cf69)

Ok we can see we have a file named product_ratings.csv. lets download it and see what is going on inside:

![image](https://github.com/user-attachments/assets/4dfec9a6-b8c5-4454-a0eb-691c287f3695)

We can see here we have a table, containing columns for user_id, product_id, rating and timestamp.

We can see diffrent ratings for diffrent producta from various users. What if we change the ratings for the Orci doll?

But first we need to find out the doll's product_id.

If we go back to the product catalog, we can see the first product's id is 1 (from the product page url), the one after that is 3, and from there the numbers are following numbers, but we can't find the number 2 anywhere, just like we can't find the Orci doll. It is safe to assume the Orci doll's product id is 2.

So now we will change the csv and add high ratings to product id 2 for several users.

To upload the modified file to the bucket we will use this command:

```
aws s3 cp ./product_ratings.csv s3://sagemaker-recommendation-bucket-q37ltzqo/product_ratings.csv --no-sign-request --acl bucket-owner-full-control
```

**Updating the model might take some time, as noted in the website.**

After waiting afew minutes, we refrresh the reccomendation page and see Orci:

![image](https://github.com/user-attachments/assets/0dbe75db-d33d-40ec-923c-b35335a9c8b0)

And we finished challenge number 2!
