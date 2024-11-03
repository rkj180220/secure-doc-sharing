import React from 'react';
import { Amplify } from 'aws-amplify';
import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import config from './amplifyconfiguration.json';
import { BrowserRouter as Router, Route, Routes, Navigate, Link } from 'react-router-dom';
import Home from './components/Home';
import Upload from './components/Upload';
import Users from './components/Users';
import { AppBar, Toolbar, Typography, Button, IconButton } from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import './App.css';

Amplify.configure(config);

function App({ signOut, user }) {
    return (
        <>
            <Router>
                <AppBar position="static" sx={{ width: '100%' }}>
                    <Toolbar>
                        <IconButton edge="start" color="inherit" aria-label="menu" sx={{ mr: 2 }}>
                            <MenuIcon />
                        </IconButton>
                        <Typography variant="h6" sx={{ flexGrow: 1 }}>
                            Secure Doc Sharing
                        </Typography>
                        <Button color="inherit" component={Link} to="/home">Home</Button>
                        <Button color="inherit" component={Link} to="/upload">Upload</Button>
                        <Button color="inherit" component={Link} to="/users">Users</Button>
                        <Button color="inherit" onClick={signOut}>Sign Out</Button>
                    </Toolbar>
                </AppBar>
                <Routes>
                    <Route path="/" element={<Navigate to="/home" />} />
                    <Route path="/home" element={<Home user={user} />} />
                    <Route path="/upload" element={<Upload user={user} />} />
                    <Route path="/users" element={<Users user={user} />} />
                </Routes>
            </Router>
        </>
    );
}

export default withAuthenticator(App);