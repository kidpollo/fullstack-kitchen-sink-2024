import os
import logging
import boto3

logger = logging.getLogger()
logger.setLevel("INFO")

from core import mathutils

def get_values():
    return mathutils.get_zeros()

# Entry point for Lambda execution
def handler(event, context):
    table_name = os.getenv('TODOS_TABLE_NAME')
    table = boto3.resource('dynamodb').Table(table_name)

    logger.info(event)
    # Handle stream of events from DynamoDB
    # to aggregate Todo statistics back to DynamoDB
    for record in event['Records']:
        todoPk = record['dynamodb']['Keys']['PK']['S']

        if todoPk.split('#')[0] != 'todo':
            logger.info(f"Skipping {todoPk} as it is not a todo")
            continue

        userStatsPk = f"userStats#{todoPk.split('#')[1]}"
        globalStatsPk = "globalStats"

        if record['eventName'] == 'INSERT':
            new_record = record['dynamodb']['NewImage']
            logger.info(f"{new_record} was deleted")
            # increment todoCount counter
            table.update_item(
                Key={'PK': userStatsPk, 'SK': 'todoStats'},
                UpdateExpression='ADD #todoCount :inc',
                ExpressionAttributeNames={'#todoCount': 'todoCount'},
                ExpressionAttributeValues={':inc': 1}
            )
            table.update_item(
                Key={'PK': globalStatsPk, 'SK': 'todoStats'},
                UpdateExpression='ADD #todoCount :inc',
                ExpressionAttributeNames={'#todoCount': 'todoCount'},
                ExpressionAttributeValues={':inc': 1}
            )

        if record['eventName'] == 'MODIFY':
            new_record = record['dynamodb']['NewImage']
            old_record = record['dynamodb']['OldImage']
            logger.info(f"{old_record} was modified to {new_record}")
            # increment counter for completed tasks and decrement for uncompleted tasks
            if old_record['completed']['BOOL'] == False and new_record['completed']['BOOL'] == True:
                table.update_item(
                    Key={'PK': userStatsPk, 'SK': 'todoStats'},
                    UpdateExpression='ADD #completed :inc',
                    ExpressionAttributeNames={'#completed': 'completed'},
                    ExpressionAttributeValues={':inc': 1}
                )
                table.update_item(
                    Key={'PK': globalStatsPk, 'SK': 'todoStats'},
                    UpdateExpression='ADD #completed :inc',
                    ExpressionAttributeNames={'#completed': 'completed'},
                    ExpressionAttributeValues={':inc': 1}
                )
            elif old_record['completed']['BOOL'] == True and new_record['completed']['BOOL'] == False:
                table.update_item(
                    Key={'PK': userStatsPk, 'SK': 'todoStats'},
                    UpdateExpression='ADD #completed :inc',
                    ExpressionAttributeNames={'#completed': 'completed'},
                    ExpressionAttributeValues={':inc': -1}
                )
                table.update_item(
                    Key={'PK': globalStatsPk, 'SK': 'todoStats'},
                    UpdateExpression='ADD #completed :inc',
                    ExpressionAttributeNames={'#completed': 'completed'},
                    ExpressionAttributeValues={':inc': -1}
                )


        if record['eventName'] == 'REMOVE':
            old_record = record['dynamodb']['OldImage']
            logger.info(f"{old_record} was deleted")
            # decrement todoCount counter
            table.update_item(
                Key={'PK': userStatsPk, 'SK': 'todoStats'},
                UpdateExpression='ADD #todoCount :inc',
                ExpressionAttributeNames={'#todoCount': 'todoCount'},
                ExpressionAttributeValues={':inc': -1}
            )
            table.update_item(
                Key={'PK': globalStatsPk, 'SK': 'todoStats'},
                UpdateExpression='ADD #todoCount :inc',
                ExpressionAttributeNames={'#todoCount': 'todoCount'},
                ExpressionAttributeValues={':inc': -1}
            )

    return event



# Entry point for local execution
if __name__ == "__main__":
    handler({}, {})
