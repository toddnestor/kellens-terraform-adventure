export const handler = async (event) => ({isAuthorized: event.headers.authorization === 'LET_ME_PASS'});
