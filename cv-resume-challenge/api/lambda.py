import json
import boto3

# Initialize DynamoDB client
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("VisitorCountTable")

def lambda_handler(event, context):
    # Fetch current count
    response = table.get_item(Key={"id": "visitor_count"})
    current_count = response.get("Item", {}).get("count", 0)

    # Increment count
    new_count = current_count + 1
    table.put_item(Item={"id": "visitor_count", "count": new_count})

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({"count": new_count}, default=int)
    }
