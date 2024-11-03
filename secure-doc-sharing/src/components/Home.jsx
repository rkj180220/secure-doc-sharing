import React, { useEffect, useState } from 'react';
import axiosInstance from '../axiosConfig';
import config from '../config';

const Home = ({ user }) => {
    const [files, setFiles] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchFiles = async () => {
            try {
                const response = await axiosInstance.post(config.apiGateway.getFiles, {});
                setFiles(response.data);
            } catch (error) {
                console.error('Error fetching files:', error);
            }
            setLoading(false);
        };

        fetchFiles();
    }, [user.id]);

    if (loading) {
        return <p>Loading...</p>;
    }

    return (
        <div>
            <h1>Welcome {user.username}</h1>
            <h2>Your Files</h2>
            <ul>
                {files.map(file => (
                    <li key={file.id}>{file.name}</li>
                ))}
            </ul>
        </div>
    );
};

export default Home;