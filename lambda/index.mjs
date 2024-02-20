export const handler = async (event) => {
  console.log(`auth header: ${event.headers.authorization}`);

  const isAuthorized = event.headers.authorization === 'LET_ME_PASS';

  console.log(`isAuthorized: ${isAuthorized}`);

  return {isAuthorized};
}
