import {Amplify} from 'aws-amplify';
import {withAuthenticator} from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import config from './amplifyconfiguration.json';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import Home from './components/Home';
import Upload from './components/Upload';
import Users from "./components/Users";

Amplify.configure(config);

function App({signOut, user}) {
    return (
        <>
            <button onClick={signOut}>Sign out</button>
            <Router>
                <Routes>
                    <Route path="/" element={<Navigate to="/home"/>}/>
                    <Route path="/home" element={<Home user={user}/>}/>
                    <Route path="/upload" element={<Upload user={user}/>}/>
                    <Route path="/users" element={<Users user={user}/>}/>

                </Routes>
            </Router>
        </>
    );
}

export default withAuthenticator(App);