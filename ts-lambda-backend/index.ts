import { APIGatewayProxyHandler } from 'aws-lambda';
import { DynamoDBClient, QueryCommand } from '@aws-sdk/client-dynamodb';

const dynamoDBClient = new DynamoDBClient();

export const handler: APIGatewayProxyHandler = async (_event, _context) => {
  const command = new QueryCommand({
    TableName: "todos",
    // KeyConditionExpression: "userId = :userId",
    // ExpressionAttributeValues: {
    //   ":userId": "123"
    // }
  });
  const result = await dynamoDBClient.send(command);
  return {
    statusCode: 200,
    body: JSON.stringify(result)
  };
};