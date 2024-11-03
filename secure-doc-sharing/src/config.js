const config = {
    apiGateway: {
        URL: 'https://9fghfmvsdh.execute-api.us-east-1.amazonaws.com/dev_env/',
        getPresignedUrl: 'file/presignedURL',
        getFiles: 'file',
        getUsers: 'listCognitoUsers',
        shareFile:'shareFile'
    }
};

export default config;