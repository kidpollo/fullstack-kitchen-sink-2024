import { APIGatewayProxyHandler } from 'aws-lambda';
import { DynamoDBClient, ScanCommand } from '@aws-sdk/client-dynamodb';

const dynamoDBClient = new DynamoDBClient();
const tableName = process.env.TODOS_TABLE_NAME || "";

export const handler: APIGatewayProxyHandler = async (_event, _context) => {
  const command = new ScanCommand({
    //  DONT DO THIS
    TableName: tableName,
  });
  const result = await dynamoDBClient.send(command);
  return {
    statusCode: 200,
    body: JSON.stringify(result)
  };
};
