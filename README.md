# Lambda as gateway to AWS

In this lab we are going to demonstrate how AWS can be easily used to deploy 
small services and to make them available to public. The focus point of this
lab is to show simple AWS services, and how they make deployment and development
of applications easier.

In this example we are going to be developing a backend for simple TODO list 
application using Python and AWS. The application is going to persist a TODO 
list and will enable retrieval of the task list from our service. 

First we are going to go through configuration of AWS resources, which are 
necessary for deploying the application. Next we are going to deploy the 
code and test it, and lastly we are going to show the weaknesses of 
click-and-configure methodology and how this can be replaced with
infrastructure-as-code approach. So let's get kickin!

## Infrastructure of TODO application

For deployment of our application we are going to be using AWS Lambda
and AWS API Gateway services.

The AWS Lambda service is going to  provide the compute resources on which
our application is going to be running. This is a so-called serverless runtime,
which means we only need to specify the code, which we would like to have executed
and AWS takes care of the rest.

Second service on our hit-list is the AWS API Gateway service. API Gateway service
is a service for managing APIs to our service, whose functionality is provided
by Lambda function. We are going to use it to specify how our users may interact
with the service. Word of caution on terminology here: API is nothing more than
a specification of how users can interact with our service.

![AWS Infrastructure with API Gateway and Lambda function](img/LambdaInfraGraph.png)

As we can see in the image above our users are going to be able to communicate with
our service via an API provided by the API Gateway. An example of interacting
with our application via Gateway is as follows:

- User makes a request according to specification provided by our API
- The request is received by API gateway
- API gateway converts the user request into format suitable for processing in 
  Lambda function and forwards it to the Lambda function
- Lambda function processes the request obtained from API gateway and responds
  in format suitable for API gateway
- API gateway converts the Lambda response to the format suitable for end-user and
  returns it back to the user
  
## Configuring the infrastructure

In this part of the lab we are going to proceed with configuring the 