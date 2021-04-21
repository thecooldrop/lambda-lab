import json
import os
import boto3
import logging


def lambda_handler(event, context):
    http_method = event["requestContext"]["http"]["method"]
    task_body = event.get("body", json.dumps([]))

    if type(task_body) is str:
        task_body = json.loads(task_body)

    logging.warning("HTTP method is: " + http_method)
    logging.warning("The body is: " + json.dumps(task_body))

    if http_method == "POST":
        return create_task(task_body)
    if http_method == "GET":
        return get_all_tasks()


def create_task(task):
    if task:
        assert "title" in task
        assert "due_date" in task

        s3 = boto3.resource("s3")
        bucket_name = os.environ['BUCKET_NAME']
        file_name = os.environ['FILEPATH']
        s3.Object(bucket_name, file_name).download_file('/tmp/tasks.txt')
        with open('/tmp/tasks.txt', 'r+') as tasks_file:
            tasks = json.loads(tasks_file.read())
            tasks.append(task)
            boto3.client('s3').put_object(Body=json.dumps(tasks).strip(), Bucket=bucket_name, Key=file_name)
            return {"statusCode": 200,
                    "body": "Task created successfully"}

    else:
        return {"errorMessage": "The task was None"}


def get_all_tasks():
    s3 = boto3.resource("s3")
    bucket_name = os.environ['BUCKET_NAME']
    file_name = os.environ['FILEPATH']
    s3.Object(bucket_name, file_name).download_file('/tmp/tasks.txt')
    with open('/tmp/tasks.txt', 'r') as tasks_file:
        tasks = json.loads(tasks_file.read())
        return {"statusCode": 200,
                "headers": {
                    "content-type": "application/json"
                },
                "body": json.dumps(tasks)}

class