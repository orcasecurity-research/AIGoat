# Objectives

 Bypass the content filtering AI system to post on the Orca Doll product page the forbidden comment:
```
"pwned"
```
Success is achieved this comment that should be filtered gets published.

# Solutions

Lets start with trying a random comment and seeing what happens:

<img src="https://github.com/user-attachments/assets/5ab345bf-b770-414b-89b3-e5f8ed96b093" width="500" height="700">


We can see the comment addition failed due to AI check. Lets take a look behind the scenes as to how this response looks when we send a comment that is approved:

<img src="https://github.com/user-attachments/assets/9174f4b0-3070-4885-8c7d-c790e155cb09" width="300" height="200">

And how the response looks when it is not approved:

<img src="https://github.com/user-attachments/assets/e5c9be03-cc6f-41ee-ade6-d0237f5d20e7" width="300" height="200">

So when a comment is approved, it will return 1, with a relevant probability, and when it is not approved it will return 0 with the relevant probability.

Well, this is an output integrity challenge. Maybe we can alter the results in some way? 

Lets see how this looks on burp: 

![image](https://github.com/user-attachments/assets/1ceb9f4b-ff08-48a6-b54d-772da7918b65)

We can see the 'is_offensive' and 'probability' values are sent with the request, what if we sent the request with the values we want to recieve?

![image](https://github.com/user-attachments/assets/8da267ae-24a7-43ec-bd25-ee36e2bcac96)


We can see the system accepted our values and posted the comment we sent


https://github.com/user-attachments/assets/d19bccbf-1b96-477d-bb4d-0974215fe43f


