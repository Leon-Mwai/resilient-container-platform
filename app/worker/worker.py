import os
import time
import boto3

sqs = boto3.client('sqs', region_name=os.getenv('AWS_REGION'))
QUEUE_URL = os.getenv('QUEUE_URL')

print('Worker started')

while True:
    response = sqs.receive_message(
        QueueUrl=QUEUE_URL,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=20
    )
    messages = response.get('Messages', [])
    for message in messages:
        print(f"Processing: {message['Body']}")
        time.sleep(5)
        sqs.delete_message(
            QueueUrl=QUEUE_URL,
            ReceiptHandle=message['ReceiptHandle']
        )
    time.sleep(1)