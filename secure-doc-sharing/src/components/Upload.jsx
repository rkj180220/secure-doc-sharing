import React, { useState } from 'react';
import axiosInstance from '../axiosConfig';
import config from '../config';
import axios from 'axios';
import './Upload.css';
import { useNavigate } from 'react-router-dom';

const Upload = ({ user }) => {
    const [file, setFile] = useState(null);
    const [message, setMessage] = useState('');
    const [isUploading, setIsUploading] = useState(false);
    const navigate = useNavigate();

    const handleFileChange = (event) => {
        setFile(event.target.files[0]);
    };

    const handleUpload = async () => {
        if (!file) {
            setMessage('Please select a file to upload.');
            return;
        }

        setIsUploading(true);
        setMessage('Uploading...'); // Reset message

        try {
            // Get presigned URL from API Gateway
            const response = await axiosInstance.post(config.apiGateway.getPresignedUrl, {
                fileName: file.name,
                fileType: file.type
            });

            const presignedUrl = response.data.pre_signedUrl;

            // Upload file to S3 using the presigned URL
            await axios.put(presignedUrl, file, {
                headers: {
                    'Content-Type': file.type
                }
            });

            setMessage('File uploaded successfully!');
            setTimeout(() => {
                navigate('/home');
            }, 3000);
        } catch (error) {
            console.error('Error uploading file:', error);
            setMessage('Error uploading file.');
        } finally {
            setIsUploading(false);
        }
    };

    return (
        <div className="upload-container">
            <h1>Upload File</h1>
            <div className="file-input">
                <input type="file" id="file-upload" onChange={handleFileChange} />
                <label htmlFor="file-upload">{file ? file.name : 'Choose a file...'}</label>
            </div>
            <button onClick={handleUpload} disabled={isUploading}>
                {isUploading ? 'Uploading...' : 'Upload'}
            </button>
            {message && <p className={`message ${isUploading ? 'uploading' : ''}`}>{message}</p>}
        </div>
    );
};

export default Upload;