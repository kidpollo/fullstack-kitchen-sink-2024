import { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { DynamoDBClient, QueryCommand, DeleteItemCommand,
         PutItemCommand, UpdateItemCommand, ReturnValue } from '@aws-sdk/client-dynamodb';
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb";
import { v4 as uuidv4 } from 'uuid';

const ddbClient = new DynamoDBClient();
const tableName = process.env.TODOS_TABLE_NAME || "";

export const handler = async (event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> => {
  // Get username form the Authorization header
  const authHeader = event.headers.authorization || '';
  const username = authHeader.split(' ')[1];
  const partitionKey = `todo#${username}`;

  try {
    switch (event.requestContext.http.method) {
      case "GET":
        const queryParams = {
          TableName: tableName,
          KeyConditionExpression: 'PK = :pkval',
          ExpressionAttributeValues: {
            ':pkval': { S: partitionKey }
          }
        };

        const queryResult = await ddbClient.send(new QueryCommand(queryParams));
        const items = queryResult.Items?.map(item => {
          const unmarshalledItem = unmarshall(item);
          return {
            id: unmarshalledItem.SK,  // Rename SK to id
            task: unmarshalledItem.task,
            completed: unmarshalledItem.completed,
            created_at: unmarshalledItem.created_at,
            updated_at: unmarshalledItem.updated_at
          };
        }) || [];

        return {
          statusCode: 200,
          body: JSON.stringify(items),
        };
      case "POST":
        if (!event.body) {
          return {
            statusCode: 400,
            body: JSON.stringify({ message: "Missing request body" }),
          };
        } else {
          if (event.body) {
            const body = JSON.parse(event.body);
            // Use the provided id or generate a new one
            const todoId = body.id ? body.id : uuidv4();

            const todoItem = {
              PK: partitionKey, // Partition key
              SK: todoId,
              created_at: new Date().toISOString(),
              task: body.task,
              completed: body.completed || false,
            };

            const params = {
              TableName: tableName,
              Item: marshall(todoItem)
            };

            await ddbClient.send(new PutItemCommand(params));

            return {
              statusCode: 201,
              body: JSON.stringify(todoItem),
            };
          }
        }
      case "PUT":
        if (event.pathParameters && event.pathParameters.id && event.body) {
          const todoId = event.pathParameters.id;
          const body = JSON.parse(event.body);

          const updateParams = {
            TableName: tableName,
            Key: marshall({
              PK: partitionKey,
              SK: todoId
            }),
            UpdateExpression: 'SET #task = :task, #completed = :completed, #updated_at = :updated_at',
            ExpressionAttributeNames: {
              '#task': 'task',
              '#completed': 'completed',
              '#updated_at': 'updated_at',
            },
            ExpressionAttributeValues: marshall({
              ':task': body.task,
              ':completed': body.completed,
              ':updated_at': new Date().toISOString()
            }),
            ReturnValues: 'UPDATED_NEW' as ReturnValue
          };

          await ddbClient.send(new UpdateItemCommand(updateParams));

          return {
            statusCode: 200,
            body: JSON.stringify({ message: "Todo updated successfully" }),
          };
        } else {
          return {
            statusCode: 400,
            body: JSON.stringify({ message: "Bad Request: Missing id or body" }),
          };
        }
      case "DELETE":
        if (event.pathParameters && event.pathParameters.id) {
          const todoId = event.pathParameters.id;

          const deleteParams = {
            TableName: tableName,
            Key: {
              PK: { S: partitionKey },
              SK: { S: todoId }
            }
          };

          await ddbClient.send(new DeleteItemCommand(deleteParams));

          return {
            statusCode: 200,
            body: JSON.stringify({ message: "Todo deleted successfully" }),
          };
        } else {
          return {
            statusCode: 400,
            body: JSON.stringify({ message: "Bad Request: Missing id" }),
          };
        }
      default:
        return {
          statusCode: 405,
          body: JSON.stringify({ message: "Method Not Allowed" }),
        };
    }
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Internal Server Error" }),
    };
  }
};
