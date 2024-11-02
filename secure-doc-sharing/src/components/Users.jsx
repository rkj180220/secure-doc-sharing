import React, { useEffect } from 'react';
import axiosInstance from '../axiosConfig';
import config from '../config';

const Users = () => {
    useEffect(() => {
        const fetchUsers = async () => {
            try {
                const response = await axiosInstance.get(config.apiGateway.getUsers);
                console.log('Response:', response.data);
            } catch (error) {
                console.error('Error fetching users:', error);
            }
        };

        fetchUsers();
    }, []);

    return (
        <div>
            <h1>Users</h1>
        </div>
    );
};

export default Users;