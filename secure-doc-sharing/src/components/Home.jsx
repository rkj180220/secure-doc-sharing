import React, { useEffect, useState } from 'react';
import axiosInstance from '../axiosConfig';
import config from '../config';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, IconButton } from '@mui/material';
import ShareIcon from '@mui/icons-material/Share';

const Home = ({ user }) => {
    const [files, setFiles] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchFiles = async () => {
            try {
                const response = await axiosInstance.post(config.apiGateway.getFiles, {
                    userId: user.id
                });
                setFiles(response.data);
            } catch (error) {
                console.error('Error fetching files:', error);
            }
            setLoading(false);
        };

        fetchFiles();
    }, [user.id]);

    const handleShare = (fileId) => {
        // Implement your share functionality here
        console.log(`Share file: ${fileId}`);
    };

    if (loading) {
        return <p>Loading...</p>;
    }

    return (
        <div>
            <h1>Welcome {user.signInDetails.loginId.split('@')[0]}</h1>
            <h2>Your Files</h2>
            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell>File ID</TableCell>
                            <TableCell>File Type</TableCell>
                            <TableCell>File Size (MB)</TableCell>
                            <TableCell>Created At</TableCell>
                            <TableCell>Updated At</TableCell>
                            <TableCell>Upload Status</TableCell>
                            <TableCell>Actions</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {files.map((file) => (
                            <TableRow key={file.FileID}>
                                <TableCell>{file.FileID}</TableCell>
                                <TableCell>{file.FileType}</TableCell>
                                <TableCell>{(file.FileSize / (1024 * 1024)).toFixed(2)}</TableCell>
                                <TableCell>{file.created_at}</TableCell>
                                <TableCell>{file.updated_at}</TableCell>
                                <TableCell>{file.UploadStatus}</TableCell>
                                <TableCell>
                                    <IconButton onClick={() => handleShare(file.FileID)}>
                                        <ShareIcon/>
                                    </IconButton>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
        </div>
    );
};

export default Home;