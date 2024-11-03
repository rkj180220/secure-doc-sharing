import React, { useEffect, useState } from 'react';
import axiosInstance from '../axiosConfig';
import config from '../config';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField, CircularProgress } from '@mui/material';
import ShareIcon from '@mui/icons-material/Share';
import CopyIcon from '@mui/icons-material/FileCopy';

const Home = ({ user }) => {
    const [files, setFiles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [open, setOpen] = useState(false);
    const [presignedUrl, setPresignedUrl] = useState('');

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

    const handleShare = async (fileId) => {
        try {
            const response = await axiosInstance.post(config.apiGateway.shareFile, {
                objectKey: fileId,
                expiration: 300 // Optional: specify expiration time in seconds
            });
            setPresignedUrl(response.data.pre_signedUrl);
            setOpen(true);
        } catch (error) {
            console.error('Error sharing file:', error);
        }
    };

    const handleClose = () => {
        setOpen(false);
        setPresignedUrl('');
    };

    const handleCopy = () => {
        navigator.clipboard.writeText(presignedUrl);
    };

    if (loading) {
        return <CircularProgress />;
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
            <Dialog open={open} onClose={handleClose}>
                <DialogTitle>Presigned URL</DialogTitle>
                <DialogContent>
                    <TextField
                        fullWidth
                        value={presignedUrl}
                        InputProps={{
                            readOnly: true,
                        }}
                    />
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleCopy} startIcon={<CopyIcon />}>Copy</Button>
                    <Button onClick={handleClose}>Close</Button>
                </DialogActions>
            </Dialog>
        </div>
    );
};

export default Home;