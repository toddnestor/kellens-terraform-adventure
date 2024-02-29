export const handler = async (event) => {
  console.log('event:', event);
  event.Records.forEach(({body}) => {
    const data = JSON.parse(body);

    console.log('data:', data);
  });
};
