import boto3
import json

s3 = boto3.client('s3')

def save_to_s3(data, filename):
    s3.put_object(Bucket='my-bucket', Key=filename, Body=json.dumps(data))
