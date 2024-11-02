import axios from 'axios';
import { fetchAuthSession, getCurrentUser } from 'aws-amplify/auth';
import config from './config';

const axiosInstance = axios.create({
    baseURL: config.apiGateway.URL
});

axiosInstance.interceptors.request.use(
    async (request) => {
        try {
            const { idToken } = (await fetchAuthSession()).tokens ?? {};
            if (idToken) {
                request.headers.Authorization = `Bearer ${idToken}`;
                console.log('Authorization header set:', request.headers.Authorization);
            } else {
                console.error('idToken is not available');
            }

            // Add userId to the request body if the method is POST
            if (request.method === 'post') {
                const { userId } = await getCurrentUser();
                if (userId) {
                    request.data = {
                        ...request.data,
                        userId: userId
                    };
                }
            }
        } catch (error) {
            console.error('Error getting user session:', error);
        }
        return request;
    },
    (error) => {
        return Promise.reject(error);
    }
);

export default axiosInstance;