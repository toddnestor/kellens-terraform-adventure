export const handler = async (event, _, callback) => {
  console.log('event:', event);

  callback(null, {
    statusCode: 200,
    body: `My favorite number is ${Math.random() * 10}`,
    headers: {
    }
  });
};
