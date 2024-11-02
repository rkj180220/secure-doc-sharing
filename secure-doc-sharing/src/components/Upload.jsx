import React, { useState } from 'react';
import axiosInstance from '../axiosConfig';
import config from '../config';

const Upload = ({ user }) => {
    const [file, setFile] = useState(null);
    const [message, setMessage] = useState('');

    const handleFileChange = (event) => {
        setFile(event.target.files[0]);
    };

    const handleUpload = async () => {
        if (!file) {
            setMessage('Please select a file to upload.');
            return;
        }

        try {
            // Get presigned URL from API Gateway
            const response = await axiosInstance.post(config.apiGateway.getPresignedUrl, {
                fileName: file.name,
                fileType: file.type
            });

            const { presignedUrl } = response.data;

            // Upload file to S3 using the presigned URL
            await axios.put(presignedUrl, file, {
                headers: {
                    'Content-Type': file.type
                }
            });

            setMessage('File uploaded successfully!');
        } catch (error) {
            console.error('Error uploading file:', error);
            setMessage('Error uploading file.');
        }
    };

    return (
        <div>
            <h1>Upload File</h1>
            <input type="file" onChange={handleFileChange} />
            <button onClick={handleUpload}>Upload</button>
            {message && <p>{message}</p>}
        </div>
    );
};

export default Upload;